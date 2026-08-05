extends Node

signal response_received(text: String)
signal chunk_received(chunk_text: String)
signal stream_started()
signal stream_completed(full_text: String)
signal grade_detected(grade: String, summary: String)
signal request_failed(error_msg: String)
signal connection_status_checked(is_online: bool)
signal models_fetched(model_ids: Array)

var http_request: HTTPRequest
var active_client: HTTPClient = null
var is_busy: bool = false
var is_streaming: bool = false

var stream_buffer: String = ""
var stream_full_text: String = ""
var stream_tool_name: String = ""
var stream_tool_args: String = ""
var grade_emitted_for_request: bool = false
var chat_history: Array = []

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func reset_chat_session(system_prompt: String = "") -> void:
	chat_history.clear()
	if system_prompt != "":
		var tool_directive = "\n\n[SYSTEM DIRECTIVE: Whenever you evaluate, grade, or re-grade the user's fiction writing exercise submission, you MUST execute the tool call function 'gradeActivity' with the letter grade (A, B, C, D, or F) and a concise feedback summary. You must also provide your full coaching critique and recommendations in your message.]"
		chat_history.append({
			"role": "system",
			"content": system_prompt + tool_directive
		})

func _get_tool_schema() -> Dictionary:
	return {
		"type": "function",
		"function": {
			"name": "gradeActivity",
			"description": "REQUIRED TOOL: Call this tool every time you evaluate the student's submission to assign a letter grade (A, B, C, D, or F) and provide a feedback summary.",
			"parameters": {
				"type": "object",
				"properties": {
					"grade": {
						"type": "string",
						"enum": ["A", "B", "C", "D", "F"],
						"description": "The letter grade awarded to the student's rewrite."
					},
					"feedback_summary": {
						"type": "string",
						"description": "A 1-sentence summary of why this grade was assigned."
					}
				},
				"required": ["grade", "feedback_summary"]
			}
		}
	}

func _get_request_headers() -> PackedStringArray:
	var headers: PackedStringArray = ["Content-Type: application/json"]
	var api_key = SaveManager.settings.get("api_key", "").strip_edges()
	if api_key != "":
		headers.append("Authorization: Bearer " + api_key)
		
	var api_url = SaveManager.settings.get("lm_studio_url", "")
	if "openrouter.ai" in api_url:
		headers.append("HTTP-Referer: https://prose-quest")
		headers.append("X-Title: Prose Quest")
		
	return headers

func _parse_url(url: String) -> Dictionary:
	var use_ssl = url.begins_with("https://")
	var clean_url = url.replace("https://", "").replace("http://", "")
	var slash_pos = clean_url.find("/")
	var host_port = clean_url
	var path = "/"
	if slash_pos != -1:
		host_port = clean_url.substr(0, slash_pos)
		path = clean_url.substr(slash_pos)
		
	var host = host_port
	var port = 443 if use_ssl else 80
	var colon_pos = host_port.find(":")
	if colon_pos != -1:
		host = host_port.substr(0, colon_pos)
		port = int(host_port.substr(colon_pos + 1))
		
	return {
		"host": host,
		"port": port,
		"path": path,
		"use_ssl": use_ssl
	}

func send_message(user_text: String) -> void:
	if is_busy:
		request_failed.emit("AI is currently generating a response. Please wait.")
		return
		
	if user_text != "":
		chat_history.append({
			"role": "user",
			"content": user_text
		})
		
	is_busy = true
	grade_emitted_for_request = false
	
	var api_url = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
	var model_name = SaveManager.settings.get("model_name", "local-model").strip_edges()
	if model_name == "":
		model_name = "local-model"
		
	var payload = {
		"model": model_name,
		"messages": chat_history,
		"temperature": 0.7,
		"stream": true,
		"tools": [_get_tool_schema()],
		"tool_choice": "auto"
	}
	
	var parsed = _parse_url(api_url)
	active_client = HTTPClient.new()
	var tls_opts: TLSOptions = TLSOptions.client_unsafe() if parsed["use_ssl"] else null
	var err = active_client.connect_to_host(parsed["host"], parsed["port"], tls_opts)
	
	if err != OK:
		# Fallback to standard HTTPRequest if client connection fails
		active_client = null
		payload["stream"] = false
		var headers = _get_request_headers()
		http_request.request(api_url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
		return
		
	stream_buffer = ""
	stream_full_text = ""
	stream_tool_name = ""
	stream_tool_args = ""
	is_streaming = true
	stream_started.emit()

func _process(_delta: float) -> void:
	if not is_streaming or active_client == null:
		return
		
	active_client.poll()
	var status = active_client.get_status()
	
	if status == HTTPClient.STATUS_CONNECTING or status == HTTPClient.STATUS_RESOLVING:
		return
		
	if status == HTTPClient.STATUS_CONNECTED:
		var api_url = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
		var parsed = _parse_url(api_url)
		var model_name = SaveManager.settings.get("model_name", "local-model").strip_edges()
		if model_name == "":
			model_name = "local-model"
			
		var payload = {
			"model": model_name,
			"messages": chat_history,
			"temperature": 0.7,
			"stream": true,
			"tools": [_get_tool_schema()],
			"tool_choice": "auto"
		}
		
		var headers = _get_request_headers()
		active_client.request(HTTPClient.METHOD_POST, parsed["path"], headers, JSON.stringify(payload))
		return
		
	if status == HTTPClient.STATUS_BODY:
		while active_client != null and is_streaming and active_client.get_status() == HTTPClient.STATUS_BODY:
			active_client.poll()
			if active_client == null or not is_streaming:
				break
			var chunk = active_client.read_response_body_chunk()
			if chunk.size() == 0:
				break
			stream_buffer += chunk.get_string_from_utf8()
			_parse_stream_buffer()
			
	if active_client != null and status in [HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_TLS_HANDSHAKE_ERROR]:
		if is_streaming:
			_finish_stream()

func _parse_stream_buffer() -> void:
	var lines = stream_buffer.split("\n")
	if not stream_buffer.ends_with("\n"):
		stream_buffer = lines[lines.size() - 1]
		lines.resize(lines.size() - 1)
	else:
		stream_buffer = ""
		
	for line in lines:
		var l = line.strip_edges()
		if l.begins_with("data:"):
			var data_str = l.substr(5).strip_edges()
			if data_str == "[DONE]":
				_finish_stream()
				return
			var json_data = JSON.parse_string(data_str)
			if json_data is Dictionary and json_data.has("choices"):
				var choices = json_data.get("choices", [])
				if choices is Array and not choices.is_empty():
					var delta = choices[0].get("delta", {})
					if delta is Dictionary and delta.has("content"):
						var chunk_str = str(delta.get("content", ""))
						if chunk_str != "" and chunk_str != "null":
							stream_full_text += chunk_str
							chunk_received.emit(chunk_str)
							
					# Accumulate streaming tool call deltas across chunks
					var tool_calls = delta.get("tool_calls", [])
					for tc in tool_calls:
						var fn = tc.get("function", {})
						if fn.has("name") and str(fn["name"]) != "":
							stream_tool_name = str(fn["name"])
							print("[AIManager] Streaming tool call started: ", stream_tool_name)
						if fn.has("arguments") and fn["arguments"] != null:
							stream_tool_args += str(fn["arguments"])

func _finish_stream() -> void:
	if not is_streaming:
		return
	is_streaming = false
	is_busy = false
	if active_client:
		active_client.close()
		active_client = null
		
	chat_history.append({
		"role": "assistant",
		"content": stream_full_text
	})
	
	response_received.emit(stream_full_text)
	stream_completed.emit(stream_full_text)
	
	print("[AIManager] Stream finished. Length: ", stream_full_text.length(), " chars.")
	
	# Process streaming tool call if received
	if not grade_emitted_for_request and stream_tool_name == "gradeActivity" and stream_tool_args != "":
		print("[AIManager] Parsing accumulated tool arguments: ", stream_tool_args)
		var args = JSON.parse_string(stream_tool_args)
		if args is Dictionary:
			var grade = str(args.get("grade", "")).to_upper().strip_edges()
			var summary = str(args.get("feedback_summary", "")).strip_edges()
			if grade in ["A", "B", "C", "D", "F"]:
				grade_emitted_for_request = true
				print("[AIManager] Tool call grade detected! Emitting grade: ", grade, " | Summary: ", summary)
				grade_detected.emit(grade, summary)
				
	if not grade_emitted_for_request:
		_fallback_regex_grade_check(stream_full_text)

func test_connection() -> void:
	var api_url = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
	var model_name = SaveManager.settings.get("model_name", "local-model").strip_edges()
	if model_name == "":
		model_name = "local-model"
		
	var test_http = HTTPRequest.new()
	add_child(test_http)
	
	test_http.request_completed.connect(func(result, code, _headers, _body):
		var is_ok = (result == HTTPRequest.RESULT_SUCCESS and (code == 200 or code == 400 or code == 405 or code == 401))
		connection_status_checked.emit(is_ok)
		test_http.queue_free()
	)
	
	var headers = _get_request_headers()
	var body = JSON.stringify({"model": model_name, "messages": [{"role": "user", "content": "ping"}]})
	test_http.request(api_url, headers, HTTPClient.METHOD_POST, body)

func fetch_available_models() -> void:
	var api_url = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
	var models_url = api_url.replace("/chat/completions", "/models")
	
	var fetch_http = HTTPRequest.new()
	add_child(fetch_http)
	
	fetch_http.request_completed.connect(func(result, code, _headers, body):
		var model_ids: Array = []
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			var json_data = JSON.parse_string(body.get_string_from_utf8())
			if json_data is Dictionary and json_data.has("data"):
				var data_list = json_data.get("data", [])
				if data_list is Array:
					for item in data_list:
						if item is Dictionary and item.has("id"):
							model_ids.append(item["id"])
		models_fetched.emit(model_ids)
		fetch_http.queue_free()
	)
	
	var headers = _get_request_headers()
	fetch_http.request(models_url, headers, HTTPClient.METHOD_GET)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	is_busy = false
	grade_emitted_for_request = false
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		var err_str = "AI server error (" + str(response_code) + "). Check your URL, Model Name, and API Key settings."
		if body.size() > 0:
			err_str += "\n" + body.get_string_from_utf8()
		request_failed.emit(err_str)
		return

	var raw_str = body.get_string_from_utf8()
	var json_data = JSON.parse_string(raw_str)
	
	if not (json_data is Dictionary) or not json_data.has("choices"):
		request_failed.emit("Invalid JSON response received from AI server.")
		return

	var choices = json_data.get("choices", [])
	if choices.is_empty():
		request_failed.emit("Empty choices array returned by AI server.")
		return

	var message = choices[0].get("message", {})
	var content_text = message.get("content", "")
	if content_text == null:
		content_text = ""
		
	chat_history.append({
		"role": "assistant",
		"content": content_text
	})
	
	response_received.emit(content_text)

	var tool_calls = message.get("tool_calls", [])
	
	for tc in tool_calls:
		var fn = tc.get("function", {})
		if fn.get("name") == "gradeActivity":
			var args_raw = fn.get("arguments", "{}")
			var args = args_raw
			if args_raw is String:
				args = JSON.parse_string(args_raw)
			if args is Dictionary:
				var grade = str(args.get("grade", "")).to_upper().strip_edges()
				var summary = str(args.get("feedback_summary", "")).strip_edges()
				if grade in ["A", "B", "C", "D", "F"]:
					grade_emitted_for_request = true
					print("[AIManager] HTTP tool call grade detected! Emitting grade: ", grade, " | Summary: ", summary)
					grade_detected.emit(grade, summary)
					break

	if not grade_emitted_for_request and content_text != "":
		_fallback_regex_grade_check(content_text)

func _fallback_regex_grade_check(text: String) -> void:
	if grade_emitted_for_request or text.strip_edges() == "":
		return
		
	print("[AIManager] Running fallback regex grade check on response text...")
	var regex = RegEx.new()
	regex.compile("(?i)\\bgrade\\b[^a-zA-Z0-9]*?(?:is|assigned|of)?\\s*[*_`\\[\\(:=]*\\s*([A-DF])\\b")
	var result = regex.search(text)
	if result:
		var grade = result.get_string(1).to_upper()
		if grade in ["A", "B", "C", "D", "F"]:
			grade_emitted_for_request = true
			print("[AIManager] Fallback Regex 1 matched grade: ", grade)
			grade_detected.emit(grade, "Grade detected in evaluation feedback.")
			return
			
	var regex2 = RegEx.new()
	regex2.compile("(?i)\\bgrade\\s+([A-DF])\\b")
	var res2 = regex2.search(text)
	if res2:
		var grade2 = res2.get_string(1).to_upper()
		if grade2 in ["A", "B", "C", "D", "F"]:
			grade_emitted_for_request = true
			print("[AIManager] Fallback Regex 2 matched grade: ", grade2)
			grade_detected.emit(grade2, "Grade detected in evaluation feedback.")
			return
			
	print("[AIManager] No grade detected via tool call or regex fallback.")

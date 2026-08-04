extends Node

signal response_received(text: String)
signal grade_detected(grade: String, summary: String)
signal request_failed(error_msg: String)
signal connection_status_checked(is_online: bool)
signal models_fetched(model_ids: Array)

var http_request: HTTPRequest
var is_busy: bool = false
var chat_history: Array = []

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func reset_chat_session(system_prompt: String = "") -> void:
	chat_history.clear()
	if system_prompt != "":
		chat_history.append({
			"role": "system",
			"content": system_prompt
		})

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
	
	var api_url = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
	var model_name = SaveManager.settings.get("model_name", "local-model").strip_edges()
	if model_name == "":
		model_name = "local-model"
		
	var headers = _get_request_headers()
	
	# Define gradeActivity tool schema
	var tool_schema = {
		"type": "function",
		"function": {
			"name": "gradeActivity",
			"description": "Call this tool to grade the student's fiction writing exercise submission with a letter grade (A, B, C, D, or F) and provide a concise feedback summary.",
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
	
	var payload = {
		"model": model_name,
		"messages": chat_history,
		"temperature": 0.7,
		"tools": [tool_schema]
	}
	
	var json_body = JSON.stringify(payload)
	var err = http_request.request(api_url, headers, HTTPClient.METHOD_POST, json_body)
	
	if err != OK:
		is_busy = false
		request_failed.emit("Failed to send HTTP request to AI server (Error code: " + str(err) + ")")

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
		
	# Store AI response in chat history
	chat_history.append({
		"role": "assistant",
		"content": content_text
	})
	
	response_received.emit(content_text)

	# 1. Check for tool_calls (OpenAI function calling format)
	var tool_calls = message.get("tool_calls", [])
	var grade_found = false
	
	for tc in tool_calls:
		var fn = tc.get("function", {})
		if fn.get("name") == "gradeActivity":
			var args_raw = fn.get("arguments", "{}")
			var args = args_raw
			if args_raw is String:
				args = JSON.parse_string(args_raw)
			if args is Dictionary:
				var grade = args.get("grade", "").to_upper()
				var summary = args.get("feedback_summary", "")
				if grade in ["A", "B", "C", "D", "F"]:
					grade_detected.emit(grade, summary)
					grade_found = true
					break

	# 2. Fallback: Regex parse grade from response text if tool call wasn't triggered
	if not grade_found and content_text != "":
		_fallback_regex_grade_check(content_text)

func _fallback_regex_grade_check(text: String) -> void:
	var regex = RegEx.new()
	# Matches "Grade: A", "Grade of B", "[Grade: A]", "Grade: A-", etc.
	regex.compile("(?i)(?:grade(?:\\s+is|\\s+assigned|\\s*:|\\s+of)?\\s*[:\\[\\s]*)([A-DF])(?![a-z])")
	var result = regex.search(text)
	if result:
		var grade = result.get_string(1).to_upper()
		if grade in ["A", "B", "C", "D", "F"]:
			grade_detected.emit(grade, "Grade detected in evaluation feedback.")

extends Control

@onready var chapter_title_label: Label = %ChapterTitleLabel
@onready var grade_badge: PanelContainer = %GradeBadge
@onready var next_chapter_button: Button = %NextChapterButton
@onready var back_button: Button = %BackButton
@onready var materials_text: RichTextLabel = %MaterialsText
@onready var activity_text: RichTextLabel = %ActivityText
@onready var chat_container: VBoxContainer = %ChatContainer
@onready var chat_scroll: ScrollContainer = %ChatScroll
@onready var message_input: TextEdit = %MessageInput
@onready var send_button: Button = %SendButton
@onready var thinking_label: Label = %ThinkingLabel
@onready var error_dialog: Control = %ErrorDialog
@onready var error_label: Label = %ErrorLabel
@onready var settings_button_dialog: Button = %SettingsButtonDialog
@onready var close_error_button: Button = %CloseErrorButton
@onready var grade_popup: Control = %GradePopup
@onready var settings_panel: Control = %SettingsPanel

const CHAT_BUBBLE = preload("res://src/ui/lesson_screen/chat_bubble.tscn")

var chapter_data: Dictionary = {}
var current_ai_bubble: MarginContainer = null
var next_chapter_id: String = ""

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	send_button.pressed.connect(_on_send_pressed)
	settings_button_dialog.pressed.connect(_on_open_settings)
	close_error_button.pressed.connect(func(): error_dialog.visible = false)
	next_chapter_button.pressed.connect(_on_next_chapter_pressed)
	
	_style_send_button()
	_style_next_button()
	
	AIManager.stream_started.connect(_on_stream_started)
	AIManager.chunk_received.connect(_on_chunk_received)
	AIManager.stream_completed.connect(_on_stream_completed)
	AIManager.response_received.connect(_on_ai_response)
	AIManager.grade_detected.connect(_on_ai_grade_detected)
	AIManager.request_failed.connect(_on_ai_error)
	
	_load_chapter()

func _style_send_button() -> void:
	send_button.add_theme_font_size_override("font_size", 16)
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("#e8a849")
	normal.set_corner_radius_all(6)
	send_button.add_theme_stylebox_override("normal", normal)
	send_button.add_theme_color_override("font_color", Color("#1a1a2e"))
	
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color("#f4be65")
	hover.set_corner_radius_all(6)
	send_button.add_theme_stylebox_override("hover", hover)
	send_button.add_theme_color_override("font_hover_color", Color("#1a1a2e"))

func _style_next_button() -> void:
	next_chapter_button.add_theme_font_size_override("font_size", 14)
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("#53d769")
	normal.set_corner_radius_all(6)
	next_chapter_button.add_theme_stylebox_override("normal", normal)
	next_chapter_button.add_theme_color_override("font_color", Color("#1a1a2e"))
	
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color("#72e084")
	hover.set_corner_radius_all(6)
	next_chapter_button.add_theme_stylebox_override("hover", hover)
	next_chapter_button.add_theme_color_override("font_hover_color", Color("#1a1a2e"))

func _load_chapter() -> void:
	chapter_data = GameManager.get_chapter(GameManager.active_chapter_id)
	if chapter_data.is_empty():
		return
		
	var cid = chapter_data.get("id", "")
	chapter_title_label.text = "CH " + str(chapter_data.get("number", 1)) + ": " + chapter_data.get("title", "").to_upper()
	
	var prog = SaveManager.get_chapter_progress(cid)
	var best_grade = prog.get("best_grade", "")
	grade_badge.set_grade(best_grade)
	
	# Determine next chapter availability
	next_chapter_id = GameManager.get_next_chapter_id(cid)
	if best_grade != "" and next_chapter_id != "":
		next_chapter_button.visible = true
	else:
		next_chapter_button.visible = false
	
	# Load Materials BBCode
	materials_text.text = chapter_data.get("principles_bbcode", "")
	activity_text.text = chapter_data.get("activity_bbcode", "")
	
	# Reset chat UI
	for child in chat_container.get_children():
		child.queue_free()
		
	# Start AI Session
	var prompt = chapter_data.get("sample_prompt", "")
	if prompt != "":
		AIManager.reset_chat_session(prompt)
		_set_thinking(true)
		AIManager.send_message("Please generate the initial flawed paragraph challenge for me to fix.")
	else:
		_add_chat_bubble("assistant", "Welcome to Chapter " + str(chapter_data.get("number", 1)) + "! Read the lesson materials on the left, then send your draft when ready.")

func _on_send_pressed() -> void:
	var text = message_input.text.strip_edges()
	if text == "" or AIManager.is_busy:
		return
		
	_add_chat_bubble("user", text)
	message_input.text = ""
	_set_thinking(true)
	
	AIManager.send_message(text)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and event.ctrl_pressed:
			if message_input.has_focus():
				_on_send_pressed()
				get_viewport().set_input_as_handled()

func _add_chat_bubble(sender: String, text: String) -> MarginContainer:
	var bubble = CHAT_BUBBLE.instantiate()
	chat_container.add_child(bubble)
	bubble.setup(sender, text)
	chat_scroll.scroll_vertical = int(chat_scroll.get_v_scroll_bar().max_value)
	return bubble

func _set_thinking(thinking: bool) -> void:
	thinking_label.visible = thinking
	send_button.disabled = thinking

func _on_stream_started() -> void:
	_set_thinking(true)
	current_ai_bubble = _add_chat_bubble("assistant", "")

func _on_chunk_received(chunk_text: String) -> void:
	_set_thinking(false)
	if current_ai_bubble != null:
		current_ai_bubble.append_chunk(chunk_text)
		chat_scroll.scroll_vertical = int(chat_scroll.get_v_scroll_bar().max_value)

func _on_stream_completed(_full_text: String) -> void:
	_set_thinking(false)
	current_ai_bubble = null

func _on_ai_response(text: String) -> void:
	_set_thinking(false)
	if current_ai_bubble == null and text != "":
		_add_chat_bubble("assistant", text)

func _on_ai_grade_detected(grade: String, summary: String) -> void:
	_set_thinking(false)
	
	var cid = chapter_data.get("id", "")
	var grade_res = SaveManager.record_chapter_grade(cid, grade)
	
	# Refresh header badge
	grade_badge.set_grade(grade_res.get("new_grade", grade))
	
	# Show next chapter button if available
	next_chapter_id = GameManager.get_next_chapter_id(cid)
	if next_chapter_id != "":
		next_chapter_button.visible = true
	
	# Trigger Grade Popup
	grade_popup.show_grade_result(grade, summary, grade_res)

func _on_next_chapter_pressed() -> void:
	if next_chapter_id != "":
		GameManager.show_chapter_comic(next_chapter_id)

func _on_ai_error(error_msg: String) -> void:
	_set_thinking(false)
	current_ai_bubble = null
	error_label.text = error_msg
	error_dialog.visible = true

func _on_open_settings() -> void:
	error_dialog.visible = false
	if settings_panel:
		settings_panel.visible = true

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.CHAPTER_LIST)

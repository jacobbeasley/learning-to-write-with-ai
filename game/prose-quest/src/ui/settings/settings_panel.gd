extends Control

@onready var ai_tab_button: Button = %AiTabButton
@onready var audio_tab_button: Button = %AudioTabButton
@onready var ai_content_container: Control = %AiContentContainer
@onready var audio_content_container: Control = %AudioContentContainer

@onready var preset_option_button: OptionButton = %PresetOptionButton
@onready var url_input: LineEdit = %UrlInput
@onready var model_input: LineEdit = %ModelInput
@onready var model_option_button: OptionButton = %ModelOptionButton
@onready var api_key_input: LineEdit = %ApiKeyInput
@onready var test_button: Button = %TestButton
@onready var status_label: Label = %StatusLabel

@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value_label: Label = %VolumeValueLabel

@onready var audio_click_option: OptionButton = %AudioClickOptionButton
@onready var audio_click_preview: Button = %AudioClickPreviewButton
@onready var audio_submit_option: OptionButton = %AudioSubmitOptionButton
@onready var audio_submit_preview: Button = %AudioSubmitPreviewButton
@onready var audio_ai_response_option: OptionButton = %AudioAiResponseOptionButton
@onready var audio_ai_response_preview: Button = %AudioAiResponsePreviewButton
@onready var audio_comic_reveal_option: OptionButton = %AudioComicRevealOptionButton
@onready var audio_comic_reveal_preview: Button = %AudioComicRevealPreviewButton
@onready var audio_grade_a_option: OptionButton = %AudioGradeAOptionButton
@onready var audio_grade_a_preview: Button = %AudioGradeAPreviewButton
@onready var audio_grade_b_option: OptionButton = %AudioGradeBOptionButton
@onready var audio_grade_b_preview: Button = %AudioGradeBPreviewButton
@onready var audio_grade_cd_option: OptionButton = %AudioGradeCdOptionButton
@onready var audio_grade_cd_preview: Button = %AudioGradeCdPreviewButton
@onready var audio_grade_f_option: OptionButton = %AudioGradeFOptionButton
@onready var audio_grade_f_preview: Button = %AudioGradeFPreviewButton
@onready var reset_audio_button: Button = %ResetAudioButton

@onready var save_button: Button = %SaveButton
@onready var close_button: Button = %CloseButton

const PRESETS = [
	{"name": "Select a Preset...", "url": "", "model": ""},
	{"name": "ChatGPT (OpenAI)", "url": "https://api.openai.com/v1/chat/completions", "model": "gpt-4o-mini"},
	{"name": "LM Studio (Local)", "url": "http://127.0.0.1:1234/v1/chat/completions", "model": "local-model"},
	{"name": "Ollama (Local)", "url": "http://127.0.0.1:11434/v1/chat/completions", "model": "gemma"},
	{"name": "Groq (Ultra-Fast Cloud)", "url": "https://api.groq.com/openai/v1/chat/completions", "model": "llama-3.3-70b-versatile"},
	{"name": "DeepSeek", "url": "https://api.deepseek.com/v1/chat/completions", "model": "deepseek-chat"},
	{"name": "OpenRouter", "url": "https://openrouter.ai/api/v1/chat/completions", "model": "meta-llama/llama-3.3-70b-instruct"},
	{"name": "Together AI", "url": "https://api.together.xyz/v1/chat/completions", "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo"},
	{"name": "Mistral AI", "url": "https://api.mistral.ai/v1/chat/completions", "model": "mistral-small-latest"},
	{"name": "LocalAI / vLLM (Local)", "url": "http://127.0.0.1:8080/v1/chat/completions", "model": "local-model"}
]

const AUDIO_CATALOG: Array[Dictionary] = [
	# Clicks
	{"path": "res://assets/audio/clicks/click_clean_sharp.wav", "name": "Clean Sharp Click", "category": "clicks"},
	{"path": "res://assets/audio/clicks/click_mechanical_snap.wav", "name": "Mechanical Snap", "category": "clicks"},
	{"path": "res://assets/audio/clicks/click_retro_blip.wav", "name": "Retro Blip", "category": "clicks"},
	{"path": "res://assets/audio/clicks/click_smooth_select.wav", "name": "Smooth Select", "category": "clicks"},
	{"path": "res://assets/audio/clicks/click_tiny_tick.wav", "name": "Tiny Tick", "category": "clicks"},
	# AI Response
	{"path": "res://assets/audio/ai_response/ai_warm_notification.wav", "name": "Warm Notification", "category": "ai_response"},
	{"path": "res://assets/audio/ai_response/ai_inquisitive_rising.wav", "name": "Inquisitive Rising", "category": "ai_response"},
	{"path": "res://assets/audio/ai_response/ai_scifi_chirp.wav", "name": "Sci-Fi Chirp", "category": "ai_response"},
	{"path": "res://assets/audio/ai_response/ai_typewriter_tick.wav", "name": "Typewriter Tick", "category": "ai_response"},
	{"path": "res://assets/audio/ai_response/ai_upbeat_chime.wav", "name": "Upbeat Chime", "category": "ai_response"},
	# Comic / Fanfares
	{"path": "res://assets/audio/comic_display/comic_mystery_reveal.wav", "name": "Mystery Reveal", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_dramatic_entrance.wav", "name": "Dramatic Entrance", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_fanfare_superhero.wav", "name": "Superhero Fanfare", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_page_pop.wav", "name": "Page Pop", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_panel_transition.wav", "name": "Panel Transition", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_retro_victory.wav", "name": "Retro Victory", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_rising_reveal.wav", "name": "Rising Reveal", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_smooth_whoosh.wav", "name": "Smooth Whoosh", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_sparkle_chime.wav", "name": "Sparkle Chime", "category": "comic_display"},
	{"path": "res://assets/audio/comic_display/comic_synth_swell.wav", "name": "Synth Swell", "category": "comic_display"}
]

const DEFAULT_AUDIO_SETTINGS = {
	"audio_click": "res://assets/audio/clicks/click_clean_sharp.wav",
	"audio_submit": "res://assets/audio/clicks/click_smooth_select.wav",
	"audio_ai_response": "res://assets/audio/ai_response/ai_warm_notification.wav",
	"audio_comic_reveal": "res://assets/audio/comic_display/comic_mystery_reveal.wav",
	"audio_grade_a": "res://assets/audio/comic_display/comic_retro_victory.wav",
	"audio_grade_b": "res://assets/audio/comic_display/comic_dramatic_entrance.wav",
	"audio_grade_cd": "res://assets/audio/comic_display/comic_sparkle_chime.wav",
	"audio_grade_f": "res://assets/audio/comic_display/comic_synth_swell.wav"
}

var fetched_models: Array = []

func _ready() -> void:
	_setup_tabs()
	_setup_presets()
	_load_ai_settings()
	_setup_audio_settings()
	
	preset_option_button.item_selected.connect(_on_preset_selected)
	model_option_button.item_selected.connect(_on_model_selected)
	test_button.pressed.connect(_on_test_pressed)
	save_button.pressed.connect(_on_save_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	AIManager.connection_status_checked.connect(_on_connection_status)
	AIManager.models_fetched.connect(_on_models_fetched)

func _setup_tabs() -> void:
	ai_tab_button.pressed.connect(func(): _select_tab("ai"))
	audio_tab_button.pressed.connect(func(): _select_tab("audio"))
	_select_tab("ai")

func _select_tab(tab_name: String) -> void:
	if tab_name == "ai":
		ai_content_container.visible = true
		audio_content_container.visible = false
		ai_tab_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		audio_tab_button.modulate = Color(0.7, 0.7, 0.7, 1.0)
	else:
		ai_content_container.visible = false
		audio_content_container.visible = true
		ai_tab_button.modulate = Color(0.7, 0.7, 0.7, 1.0)
		audio_tab_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _load_ai_settings() -> void:
	url_input.text = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
	model_input.text = SaveManager.settings.get("model_name", "local-model")
	api_key_input.text = SaveManager.settings.get("api_key", "")

func _setup_presets() -> void:
	preset_option_button.clear()
	for p in PRESETS:
		preset_option_button.add_item(p["name"])

func _on_preset_selected(index: int) -> void:
	if index > 0 and index < PRESETS.size():
		var p = PRESETS[index]
		if p["url"] != "":
			url_input.text = p["url"]
		if p["model"] != "":
			model_input.text = p["model"]

func _on_test_pressed() -> void:
	status_label.text = "Testing connection..."
	status_label.add_theme_color_override("font_color", Color("#e8a849"))
	
	SaveManager.settings["lm_studio_url"] = url_input.text.strip_edges()
	SaveManager.settings["model_name"] = model_input.text.strip_edges()
	SaveManager.settings["api_key"] = api_key_input.text.strip_edges()
	
	AIManager.test_connection()

func _on_connection_status(is_online: bool) -> void:
	if is_online:
		status_label.text = "Connection Successful! Fetching models..."
		status_label.add_theme_color_override("font_color", Color("#53d769"))
		AIManager.fetch_available_models()
	else:
		status_label.text = "Connection Failed! Check URL, Model & Key."
		status_label.add_theme_color_override("font_color", Color("#e94560"))

func _on_models_fetched(model_ids: Array) -> void:
	fetched_models = model_ids.duplicate()
	fetched_models.sort_custom(func(a, b): return str(a).to_lower() < str(b).to_lower())
	model_option_button.clear()
	
	if not fetched_models.is_empty():
		status_label.text = "Connected (" + str(fetched_models.size()) + " models found!)"
		model_option_button.add_item("Select Fetched Model...")
		for mid in fetched_models:
			model_option_button.add_item(str(mid))
			
		model_option_button.visible = true
	else:
		model_option_button.visible = false

func _on_model_selected(index: int) -> void:
	if index > 0 and index <= fetched_models.size():
		var chosen_model = fetched_models[index - 1]
		model_input.text = chosen_model
		SaveManager.settings["model_name"] = chosen_model

# --- Audio Settings Logic ---

func _setup_audio_settings() -> void:
	var current_vol = float(SaveManager.settings.get("sfx_volume", 1.0)) * 100.0
	volume_slider.value = current_vol
	volume_value_label.text = str(round(current_vol)) + "%"
	
	volume_slider.value_changed.connect(func(val: float):
		volume_value_label.text = str(round(val)) + "%"
	)
	
	_populate_audio_dropdown(audio_click_option, "clicks", SaveManager.settings.get("audio_click", DEFAULT_AUDIO_SETTINGS["audio_click"]))
	_populate_audio_dropdown(audio_submit_option, "clicks", SaveManager.settings.get("audio_submit", DEFAULT_AUDIO_SETTINGS["audio_submit"]))
	_populate_audio_dropdown(audio_ai_response_option, "ai_response", SaveManager.settings.get("audio_ai_response", DEFAULT_AUDIO_SETTINGS["audio_ai_response"]))
	_populate_audio_dropdown(audio_comic_reveal_option, "comic_display", SaveManager.settings.get("audio_comic_reveal", DEFAULT_AUDIO_SETTINGS["audio_comic_reveal"]))
	_populate_audio_dropdown(audio_grade_a_option, "comic_display", SaveManager.settings.get("audio_grade_a", DEFAULT_AUDIO_SETTINGS["audio_grade_a"]))
	_populate_audio_dropdown(audio_grade_b_option, "comic_display", SaveManager.settings.get("audio_grade_b", DEFAULT_AUDIO_SETTINGS["audio_grade_b"]))
	_populate_audio_dropdown(audio_grade_cd_option, "comic_display", SaveManager.settings.get("audio_grade_cd", DEFAULT_AUDIO_SETTINGS["audio_grade_cd"]))
	_populate_audio_dropdown(audio_grade_f_option, "comic_display", SaveManager.settings.get("audio_grade_f", DEFAULT_AUDIO_SETTINGS["audio_grade_f"]))
	
	audio_click_option.item_selected.connect(func(_idx): _preview_sound(audio_click_option))
	audio_submit_option.item_selected.connect(func(_idx): _preview_sound(audio_submit_option))
	audio_ai_response_option.item_selected.connect(func(_idx): _preview_sound(audio_ai_response_option))
	audio_comic_reveal_option.item_selected.connect(func(_idx): _preview_sound(audio_comic_reveal_option))
	audio_grade_a_option.item_selected.connect(func(_idx): _preview_sound(audio_grade_a_option))
	audio_grade_b_option.item_selected.connect(func(_idx): _preview_sound(audio_grade_b_option))
	audio_grade_cd_option.item_selected.connect(func(_idx): _preview_sound(audio_grade_cd_option))
	audio_grade_f_option.item_selected.connect(func(_idx): _preview_sound(audio_grade_f_option))
	
	audio_click_preview.pressed.connect(func(): _preview_sound(audio_click_option))
	audio_submit_preview.pressed.connect(func(): _preview_sound(audio_submit_option))
	audio_ai_response_preview.pressed.connect(func(): _preview_sound(audio_ai_response_option))
	audio_comic_reveal_preview.pressed.connect(func(): _preview_sound(audio_comic_reveal_option))
	audio_grade_a_preview.pressed.connect(func(): _preview_sound(audio_grade_a_option))
	audio_grade_b_preview.pressed.connect(func(): _preview_sound(audio_grade_b_option))
	audio_grade_cd_preview.pressed.connect(func(): _preview_sound(audio_grade_cd_option))
	audio_grade_f_preview.pressed.connect(func(): _preview_sound(audio_grade_f_option))
	
	reset_audio_button.pressed.connect(_on_reset_audio_defaults)

func _populate_audio_dropdown(opt_btn: OptionButton, primary_category: String, selected_path: String) -> void:
	opt_btn.clear()
	var item_index = 0
	var select_target_index = 0
	
	# 1. Primary category items
	var primary_items: Array[Dictionary] = []
	var other_items: Array[Dictionary] = []
	
	for entry in AUDIO_CATALOG:
		if entry["category"] == primary_category:
			primary_items.append(entry)
		else:
			other_items.append(entry)
			
	for entry in primary_items:
		opt_btn.add_item(entry["name"])
		opt_btn.set_item_metadata(item_index, entry["path"])
		if entry["path"] == selected_path:
			select_target_index = item_index
		item_index += 1
		
	if not other_items.is_empty():
		opt_btn.add_separator("--- All Sound Effects ---")
		item_index += 1
		
		for entry in other_items:
			opt_btn.add_item(entry["name"])
			opt_btn.set_item_metadata(item_index, entry["path"])
			if entry["path"] == selected_path:
				select_target_index = item_index
			item_index += 1
			
	opt_btn.select(select_target_index)

func _preview_sound(opt_btn: OptionButton) -> void:
	var idx = opt_btn.selected
	if idx >= 0:
		var path = opt_btn.get_item_metadata(idx)
		if path is String and path != "":
			var am = get_node_or_null("/root/AudioManager")
			if am:
				# Apply transient slider volume for preview
				am.master_sfx_volume = volume_slider.value / 100.0
				am.play_sound_path(path)

func _select_dropdown_by_path(opt_btn: OptionButton, path: String) -> void:
	for i in range(opt_btn.item_count):
		if opt_btn.get_item_metadata(i) == path:
			opt_btn.select(i)
			return

func _on_reset_audio_defaults() -> void:
	volume_slider.value = 100.0
	volume_value_label.text = "100%"
	
	_select_dropdown_by_path(audio_click_option, DEFAULT_AUDIO_SETTINGS["audio_click"])
	_select_dropdown_by_path(audio_submit_option, DEFAULT_AUDIO_SETTINGS["audio_submit"])
	_select_dropdown_by_path(audio_ai_response_option, DEFAULT_AUDIO_SETTINGS["audio_ai_response"])
	_select_dropdown_by_path(audio_comic_reveal_option, DEFAULT_AUDIO_SETTINGS["audio_comic_reveal"])
	_select_dropdown_by_path(audio_grade_a_option, DEFAULT_AUDIO_SETTINGS["audio_grade_a"])
	_select_dropdown_by_path(audio_grade_b_option, DEFAULT_AUDIO_SETTINGS["audio_grade_b"])
	_select_dropdown_by_path(audio_grade_cd_option, DEFAULT_AUDIO_SETTINGS["audio_grade_cd"])
	_select_dropdown_by_path(audio_grade_f_option, DEFAULT_AUDIO_SETTINGS["audio_grade_f"])

# --- Save & Close Handlers ---

func _on_save_pressed() -> void:
	# Save AI Settings
	SaveManager.settings["lm_studio_url"] = url_input.text.strip_edges()
	SaveManager.settings["model_name"] = model_input.text.strip_edges()
	SaveManager.settings["api_key"] = api_key_input.text.strip_edges()
	
	# Save Audio Settings
	SaveManager.settings["sfx_volume"] = volume_slider.value / 100.0
	SaveManager.settings["audio_click"] = audio_click_option.get_item_metadata(audio_click_option.selected)
	SaveManager.settings["audio_submit"] = audio_submit_option.get_item_metadata(audio_submit_option.selected)
	SaveManager.settings["audio_ai_response"] = audio_ai_response_option.get_item_metadata(audio_ai_response_option.selected)
	SaveManager.settings["audio_comic_reveal"] = audio_comic_reveal_option.get_item_metadata(audio_comic_reveal_option.selected)
	SaveManager.settings["audio_grade_a"] = audio_grade_a_option.get_item_metadata(audio_grade_a_option.selected)
	SaveManager.settings["audio_grade_b"] = audio_grade_b_option.get_item_metadata(audio_grade_b_option.selected)
	SaveManager.settings["audio_grade_cd"] = audio_grade_cd_option.get_item_metadata(audio_grade_cd_option.selected)
	SaveManager.settings["audio_grade_f"] = audio_grade_f_option.get_item_metadata(audio_grade_f_option.selected)
	
	SaveManager.save_settings()
	
	var am = get_node_or_null("/root/AudioManager")
	if am:
		am.reload_audio_settings()
		
	visible = false

func _on_close_pressed() -> void:
	visible = false

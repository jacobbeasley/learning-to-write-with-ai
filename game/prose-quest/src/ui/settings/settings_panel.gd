extends Control

@onready var preset_option_button: OptionButton = %PresetOptionButton
@onready var url_input: LineEdit = %UrlInput
@onready var model_input: LineEdit = %ModelInput
@onready var model_option_button: OptionButton = %ModelOptionButton
@onready var api_key_input: LineEdit = %ApiKeyInput
@onready var test_button: Button = %TestButton
@onready var status_label: Label = %StatusLabel
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

var fetched_models: Array = []

func _ready() -> void:
	_setup_presets()
	
	url_input.text = SaveManager.settings.get("lm_studio_url", "http://127.0.0.1:1234/v1/chat/completions")
	model_input.text = SaveManager.settings.get("model_name", "local-model")
	api_key_input.text = SaveManager.settings.get("api_key", "")
	
	preset_option_button.item_selected.connect(_on_preset_selected)
	model_option_button.item_selected.connect(_on_model_selected)
	test_button.pressed.connect(_on_test_pressed)
	save_button.pressed.connect(_on_save_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	AIManager.connection_status_checked.connect(_on_connection_status)
	AIManager.models_fetched.connect(_on_models_fetched)

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
	fetched_models = model_ids
	model_option_button.clear()
	
	if not model_ids.is_empty():
		status_label.text = "Connected (" + str(model_ids.size()) + " models found!)"
		model_option_button.add_item("Select Fetched Model...")
		for mid in model_ids:
			model_option_button.add_item(str(mid))
			
		model_option_button.visible = true
	else:
		model_option_button.visible = false

func _on_model_selected(index: int) -> void:
	if index > 0 and index <= fetched_models.size():
		var chosen_model = fetched_models[index - 1]
		model_input.text = chosen_model
		SaveManager.settings["model_name"] = chosen_model

func _on_save_pressed() -> void:
	SaveManager.settings["lm_studio_url"] = url_input.text.strip_edges()
	SaveManager.settings["model_name"] = model_input.text.strip_edges()
	SaveManager.settings["api_key"] = api_key_input.text.strip_edges()
	SaveManager.save_settings()
	visible = false

func _on_close_pressed() -> void:
	visible = false

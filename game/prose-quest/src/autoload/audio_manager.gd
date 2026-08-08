extends Node

# Preloaded Audio Streams
var sound_click: AudioStream = preload("res://assets/audio/clicks/click_clean_sharp.wav")
var sound_submit: AudioStream = preload("res://assets/audio/clicks/click_smooth_select.wav")
var sound_ai_response: AudioStream = preload("res://assets/audio/ai_response/ai_warm_notification.wav")
var sound_typewriter: AudioStream = preload("res://assets/audio/clicks/click_tiny_tick.wav")
var sound_typing_loop: AudioStream = preload("res://assets/audio/ai_response/dragon-studio-keyboard-typing-sound-effect-335503.mp3")
var sound_comic_reveal: AudioStream = preload("res://assets/audio/comic_display/comic_mystery_reveal.wav")

var sound_grade_a: AudioStream = preload("res://assets/audio/comic_display/comic_retro_victory.wav")
var sound_grade_b: AudioStream = preload("res://assets/audio/comic_display/comic_dramatic_entrance.wav")
var sound_grade_cd: AudioStream = preload("res://assets/audio/comic_display/comic_sparkle_chime.wav")
var sound_grade_f: AudioStream = preload("res://assets/audio/comic_display/comic_synth_swell.wav")

const POOL_SIZE = 8
var _players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _typing_loop_player: AudioStreamPlayer = null

var master_sfx_volume: float = 1.0

func _ready() -> void:
	# Create pool of AudioStreamPlayers for polyphonic sound effect playback
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		_players.append(p)
		
	# Dedicated player for continuous keyboard typing sound effect
	_typing_loop_player = AudioStreamPlayer.new()
	_typing_loop_player.bus = &"Master"
	_typing_loop_player.stream = sound_typing_loop
	# 35% volume conversion: 20 * log10(0.35) ≈ -9.1 dB
	_typing_loop_player.volume_db = -9.1
	add_child(_typing_loop_player)
	
	reload_audio_settings()
	
	# Connect to tree signals to automatically hook button clicks
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons(get_tree().root)

func reload_audio_settings() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm == null or not sm.settings:
		return
	
	master_sfx_volume = clampf(float(sm.settings.get("sfx_volume", 1.0)), 0.0, 1.0)
	
	_load_stream_setting("audio_click", func(s): sound_click = s)
	_load_stream_setting("audio_submit", func(s): sound_submit = s)
	_load_stream_setting("audio_ai_response", func(s): sound_ai_response = s)
	_load_stream_setting("audio_comic_reveal", func(s): sound_comic_reveal = s)
	_load_stream_setting("audio_grade_a", func(s): sound_grade_a = s)
	_load_stream_setting("audio_grade_b", func(s): sound_grade_b = s)
	_load_stream_setting("audio_grade_cd", func(s): sound_grade_cd = s)
	_load_stream_setting("audio_grade_f", func(s): sound_grade_f = s)
	
	if _typing_loop_player != null:
		var vol_db = linear_to_db(master_sfx_volume) if master_sfx_volume > 0.001 else -80.0
		_typing_loop_player.volume_db = -9.1 + vol_db

func _load_stream_setting(setting_key: String, setter: Callable) -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm and sm.settings.has(setting_key):
		var path = sm.settings[setting_key]
		if typeof(path) == TYPE_STRING and ResourceLoader.exists(path):
			var res = ResourceLoader.load(path)
			if res is AudioStream:
				setter.call(res)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node as BaseButton)

func _connect_existing_buttons(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node as BaseButton)
	for child in node.get_children():
		_connect_existing_buttons(child)

func _hook_button(btn: BaseButton) -> void:
	if not btn.pressed.is_connected(play_click):
		btn.pressed.connect(play_click)

func _play_stream(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	if master_sfx_volume <= 0.001:
		return
	var player = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db + linear_to_db(master_sfx_volume)
	player.pitch_scale = pitch_scale
	player.play()

# --- Public API Methods ---

func play_sound(sound_name: String, base_volume_db: float = 0.0) -> void:
	match sound_name.strip_edges().to_lower():
		"click":
			play_click()
		"submit":
			play_submit()
		"ai_response":
			play_ai_response()
		"comic_reveal":
			play_comic_reveal()
		"typing":
			play_typing()
		"grade_a":
			_play_stream(sound_grade_a, base_volume_db)
		"grade_b":
			_play_stream(sound_grade_b, base_volume_db)
		"grade_cd":
			_play_stream(sound_grade_cd, base_volume_db)
		"grade_f":
			_play_stream(sound_grade_f, base_volume_db)
		_:
			_play_stream(sound_click, -4.0 + base_volume_db)

func play_sound_path(res_path: String, base_volume_db: float = 0.0) -> void:
	if ResourceLoader.exists(res_path):
		var stream = ResourceLoader.load(res_path)
		if stream is AudioStream:
			_play_stream(stream, base_volume_db)

func play_click() -> void:
	_play_stream(sound_click, -4.0)

func play_submit() -> void:
	_play_stream(sound_submit, -2.0)

func play_typing() -> void:
	# Soft keyboard key tap with pitch randomization for realistic typing feel
	var random_pitch = randf_range(0.92, 1.08)
	_play_stream(sound_typewriter, -12.0, random_pitch)

func start_typing_loop() -> void:
	if master_sfx_volume <= 0.001:
		return
	if _typing_loop_player != null and not _typing_loop_player.playing:
		_typing_loop_player.play()

func stop_typing_loop() -> void:
	if _typing_loop_player != null and _typing_loop_player.playing:
		_typing_loop_player.stop()

func play_ai_response() -> void:
	_play_stream(sound_ai_response, 0.0)

func play_comic_reveal() -> void:
	_play_stream(sound_comic_reveal, 0.0)

func play_grade(grade_letter: String) -> void:
	var clean_grade = grade_letter.strip_edges().to_upper()
	if clean_grade.begins_with("A"):
		play_sound("grade_a")
	elif clean_grade.begins_with("B"):
		play_sound("grade_b")
	elif clean_grade.begins_with("C") or clean_grade.begins_with("D"):
		play_sound("grade_cd")
	elif clean_grade.begins_with("F"):
		play_sound("grade_f")
	else:
		play_sound("grade_cd")


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
	
	# Connect to tree signals to automatically hook button clicks
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons(get_tree().root)

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
	var player = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

# --- Public API Methods ---

func play_click() -> void:
	_play_stream(sound_click, -4.0)

func play_submit() -> void:
	_play_stream(sound_submit, -2.0)

func play_typing() -> void:
	# Soft keyboard key tap with pitch randomization for realistic typing feel
	var random_pitch = randf_range(0.92, 1.08)
	_play_stream(sound_typewriter, -12.0, random_pitch)

func start_typing_loop() -> void:
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
		_play_stream(sound_grade_a, 0.0)
	elif clean_grade.begins_with("B"):
		_play_stream(sound_grade_b, 0.0)
	elif clean_grade.begins_with("C") or clean_grade.begins_with("D"):
		_play_stream(sound_grade_cd, 0.0)
	elif clean_grade.begins_with("F"):
		_play_stream(sound_grade_f, 0.0)
	else:
		_play_stream(sound_grade_cd, 0.0)

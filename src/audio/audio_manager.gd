class_name AudioManager
extends Node


const SAMPLE_RATE: float = 44100.0

var _click_player: AudioStreamPlayer
var _confirm_player: AudioStreamPlayer
var _error_player: AudioStreamPlayer
var _cash_player: AudioStreamPlayer
var _arrive_player: AudioStreamPlayer

var is_muted: bool = false


func _ready() -> void:
	_click_player = _create_generator_player()
	_confirm_player = _create_generator_player()
	_error_player = _create_generator_player()
	_cash_player = _create_generator_player()
	_arrive_player = _create_generator_player()

	add_child(_click_player)
	add_child(_confirm_player)
	add_child(_error_player)
	add_child(_cash_player)
	add_child(_arrive_player)


func _create_generator_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = 1.0
	player.stream = stream
	return player


func set_muted(value: bool) -> void:
	is_muted = value


func play_click() -> void:
	if is_muted:
		return
	_play_tone(_click_player, 800.0, 0.2)


func play_confirm() -> void:
	if is_muted:
		return
	_play_two_tone(_confirm_player, 400.0, 600.0, 0.15)


func play_error() -> void:
	if is_muted:
		return
	_play_tone(_error_player, 200.0, 0.3)


func play_cash() -> void:
	if is_muted:
		return
	_play_tone(_cash_player, 1200.0, 0.1)


func play_train_arrive() -> void:
	if is_muted:
		return
	_play_noise_burst(_arrive_player, 0.3)


func _play_tone(player: AudioStreamPlayer, freq: float, duration: float) -> void:
	player.stop()
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if playback == null:
		return

	var num_frames: int = int(SAMPLE_RATE * duration)
	var buffer := PackedVector2Array()
	buffer.resize(num_frames)

	for i in range(num_frames):
		var t: float = float(i) / SAMPLE_RATE
		var sample: float = sin(TAU * freq * t)
		var envelope: float = _envelope(t, duration, 0.01, 0.05)
		sample *= envelope * 0.3
		buffer[i] = Vector2(sample, sample)

	playback.push_buffer(buffer)


func _play_two_tone(player: AudioStreamPlayer, freq1: float, freq2: float, duration_each: float) -> void:
	player.stop()
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if playback == null:
		return

	var total_duration: float = duration_each * 2.0
	var num_frames: int = int(SAMPLE_RATE * total_duration)
	var buffer := PackedVector2Array()
	buffer.resize(num_frames)

	for i in range(num_frames):
		var t: float = float(i) / SAMPLE_RATE
		var freq: float = freq1 if t < duration_each else freq2
		var sample: float = sin(TAU * freq * t)
		var envelope: float = _envelope(t, total_duration, 0.01, 0.05)
		sample *= envelope * 0.3
		buffer[i] = Vector2(sample, sample)

	playback.push_buffer(buffer)


func _play_noise_burst(player: AudioStreamPlayer, duration: float) -> void:
	player.stop()
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if playback == null:
		return

	var num_frames: int = int(SAMPLE_RATE * duration)
	var buffer := PackedVector2Array()
	buffer.resize(num_frames)

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in range(num_frames):
		var t: float = float(i) / SAMPLE_RATE
		var sample: float = rng.randf_range(-1.0, 1.0)
		# Modulate like a steam chuff: slow AM
		sample *= (sin(TAU * 6.0 * t) * 0.4 + 0.6)
		var envelope: float = _envelope(t, duration, 0.02, 0.1)
		sample *= envelope * 0.3
		buffer[i] = Vector2(sample, sample)

	playback.push_buffer(buffer)


func _envelope(t: float, duration: float, attack: float, release: float) -> float:
	if duration <= 0.0:
		return 0.0
	if t < attack:
		return t / attack if attack > 0.0 else 1.0
	if t > duration - release:
		return maxf(0.0, (duration - t) / release) if release > 0.0 else 0.0
	return 1.0

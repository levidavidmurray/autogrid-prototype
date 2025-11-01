extends Node

@onready var sfx_move: AudioStreamPlayer = $SFX_Move
@onready var sfx_body_impact: AudioStreamPlayer = $SFX_BodyImpact


func play_sound(data: SoundData) -> AudioStreamPlayer:
	var player = _create_player_for_data(data)
	player.finished.connect(player.queue_free)
	add_child(player)
	if data.delay > 0.0:
		G.wait(data.delay).connect(player.play)
	else:
		player.play()
	
	return player


func play_stream(stream: AudioStream, volume_db: float = 0.0) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.volume_db = volume_db
	add_child(player)
	player.play()
	return player


func _create_player_for_data(data: SoundData) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = data.stream
	player.volume_db = data.volume_db
	player.pitch_scale = data.pitch_scale
	return player

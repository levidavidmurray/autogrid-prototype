extends Node

@onready var sfx_move: AudioStreamPlayer = $SFX_Move


func play_stream(stream: AudioStream, volume_db: float = 0.0) -> void:
    var player = AudioStreamPlayer.new()
    player.stream = stream
    player.finished.connect(player.queue_free)
    player.volume_db = volume_db
    add_child(player)
    player.play()

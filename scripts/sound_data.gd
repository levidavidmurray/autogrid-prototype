class_name SoundData
extends RefCounted

var stream: AudioStream
var volume_db: float = 0.0
var pitch_scale: float = 1.0
var delay: float = 0.0

func _init(_stream: AudioStream, _volume_db: float = 0.0, _pitch_scale: float = 1.0, _delay: float = 0.0) -> void:
	self.stream = _stream
	self.volume_db = _volume_db
	self.pitch_scale = _pitch_scale
	self.delay = _delay


func _to_string() -> String:
	return stream.resource_path

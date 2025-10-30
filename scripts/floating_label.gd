class_name FloatingLabel
extends Label3D

var lifetime: float = 0.5
var direction: Vector3 = Vector3.UP
var speed: float = 1.5

var elapsed_time: float = 0.0

func _init(_text: String) -> void:
    text = _text
    outline_size = 0
    billboard = BaseMaterial3D.BILLBOARD_ENABLED
    no_depth_test = true


func _process(delta: float) -> void:
    var lifetime_t = elapsed_time / lifetime
    global_position += direction * speed * delta
    elapsed_time += delta
    if lifetime_t > 0.5:
        modulate.a = remap(lifetime_t, 0.5, 1.0, 1.0, 0.0)
    if elapsed_time >= lifetime:
        queue_free()

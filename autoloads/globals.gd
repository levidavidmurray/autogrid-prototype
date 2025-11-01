@tool
extends Node3D

func _enter_tree() -> void:
	Log.current_log_level = Log.LogLevel.DEBUG


func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0


func wait(time: float) -> Signal:
	return get_tree().create_timer(time).timeout


func cam_mouse_raycast(mask: int = 1 << 0):
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mouse_pos)
	var end = cam.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
	return space_state.intersect_ray(query)


func do_raycast(
	origin: Vector3, dir: Vector3, length: float = 100.0, mask: int = 1 << 0, exclude: Array[RID] = []
) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var end = origin + dir * length
	var query = PhysicsRayQueryParameters3D.create(origin, end, mask)
	query.exclude = exclude
	return space_state.intersect_ray(query)


func get_bezier_position(origin_pos: Vector3, origin_control: Vector3, target_pos: Vector3, target_control: Vector3, t: float):
	var a = origin_pos.lerp(origin_control, t)
	var b = origin_control.lerp(target_control, t)
	var c = target_control.lerp(target_pos, t)
	var d = a.lerp(b, t)
	var e = b.lerp(c, t)
	return d.lerp(e, t)


func floating_label(text: String, label_pos: Vector3) -> FloatingLabel:
	var label = FloatingLabel.new(text)
	add_child(label)
	label.global_position = label_pos
	return label


func color_to_hsv(color: Color) -> Vector3:
	var h: float
	var s: float
	var v: float

	var r = color.r
	var g = color.g
	var b = color.b

	var max_val = max(r, g, b)
	var min_val = min(r, g, b)
	var delta = max_val - min_val

	v = max_val

	if max_val == 0:
		s = 0
		h = 0 # Undefined, but often set to 0
	else:
		s = delta / max_val
		if delta == 0:
			h = 0 # Undefined, but often set to 0
		elif max_val == r:
			h = (g - b) / delta
		elif max_val == g:
			h = (b - r) / delta + 2
		else: # max_val == b
			h = (r - g) / delta + 4
		h /= 6.0 # Normalize hue to 0-1 range
		if h < 0:
			h += 1.0

	return Vector3(h, s, v)

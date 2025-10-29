class_name GridRunner
extends Node3D

enum EState {
	IDLE,
	MOVING
}

var grid: Grid
var current_cell: CellData
var is_cell_dirty: bool = true
var debug_label: Label3D

var state: EState = EState.MOVING
var run_direction: Vector2i = Vector2i(1, 0)
var move_interval: float = 0.5
var jump_time: float = 0.35
var last_move_time: float
var jump_time_remaining: float
var scale_tween: Tween
var shape: Node3D

var is_moving: bool:
	get():
		return state == EState.MOVING


func _ready() -> void:
	last_move_time = G.get_time()
	jump_time_remaining = jump_time


func _process(delta: float) -> void:
	if not debug_label:
		_create_debug_label()

	_calculate_jump(delta)


func _calculate_jump(delta: float):
	var config = DebugDraw3D.new_scoped_config()
	config.set_thickness(0.01)
	config.set_no_depth_test(true)

	var next_cell: CellData = _get_next_cell()
	debug_label.hide()
	var origin_pos = current_cell.position
	var origin_control = origin_pos + Vector3(0.0, 1.0, 0.0)
	var target_pos = next_cell.position
	var target_control = target_pos + Vector3(0.0, 1.0, 0.0)

	jump_time = 0.35
	var land_delay_time = 0.5
	if G.get_time() - last_move_time < land_delay_time:
		return

	var elapsed_time = clampf(jump_time - jump_time_remaining, 0.0, jump_time)
	var t = Tween.interpolate_value(0.0, 1.0, elapsed_time, jump_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	var jump_pos = G.get_bezier_position(origin_pos, origin_control, target_pos, target_control, t)
	global_position = jump_pos
	jump_time_remaining -= delta

	if t >= 0.5 and (not scale_tween or not scale_tween.is_running()):
		scale_tween = create_tween()
		scale_tween.tween_property(shape, "scale", Vector3(1.2, 0.8, 1.2), 0.2)
		scale_tween.tween_property(shape, "scale", Vector3.ONE, 0.2)

	if t >= 1.0:
		# Single frame land
		current_cell = next_cell
		last_move_time = G.get_time()
		jump_time_remaining = jump_time



func _create_debug_label() -> void:
	debug_label = Label3D.new()
	debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	debug_label.position.y = 1.0
	add_child(debug_label)


func _get_next_cell() -> CellData:
	var cur_coord: Vector2i = current_cell.coord
	if run_direction.x == 1 and cur_coord.x == grid.grid_size.x - 1:
		run_direction.x = -1
	elif run_direction.x == -1 and cur_coord.x == 0:
		run_direction.x = 1

	if run_direction.y == 1 and cur_coord.y == grid.grid_size.y - 1:
		run_direction.y = -1
	elif run_direction.y == -1 and cur_coord.y == 0:
		run_direction.y = 1

	return grid.grid_to_cell(cur_coord + run_direction)

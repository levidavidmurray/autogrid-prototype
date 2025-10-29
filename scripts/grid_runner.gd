class_name GridRunner
extends Node3D

enum EState {
	IDLE,
	MOVING
}

signal move_started
signal move_finished
signal cell_changed(prev_cell: CellData, new_cell: CellData)

var grid: Grid

var current_cell: CellData:
	set(value):
		var prev_cell = current_cell
		current_cell = value
		if current_cell != prev_cell:
			cell_changed.emit(prev_cell, current_cell)

var is_cell_dirty: bool = true
var debug_label: Label3D

var state: EState = EState.IDLE
var run_direction: Vector2i = Vector2i(1, 0)
var move_interval: float = 0.5
var jump_time: float = 0.35
var last_move_time: float
var jump_time_remaining: float
var scale_tween: Tween
var shape: Node3D

var move_path: Array[CellData]
var move_path_index: int = 0

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


func can_move() -> bool:
	return state == EState.IDLE


func move(p_path: Array[CellData]) -> void:
	assert(can_move(), "[GridRunner::move] can_move() != true")
	assert(current_cell == p_path[0], "[GridRunner::move] path must start at runner's current_cell")
	move_path = p_path.duplicate()
	move_path_index = 0
	last_move_time = G.get_time()
	jump_time_remaining = jump_time
	move_started.emit()


func snap_to_current_cell() -> void:
	# TODO: Look into refactoring current_cell usage
	global_position = current_cell.position


func _calculate_jump(delta: float):
	var config = DebugDraw3D.new_scoped_config()
	config.set_thickness(0.01)
	config.set_no_depth_test(true)

	var next_cell: CellData = _get_next_cell()

	if next_cell == null:
		return
	
	state = EState.MOVING

	debug_label.hide()
	var origin_pos = current_cell.position
	var origin_control = origin_pos + Vector3(0.0, 0.5, 0.0)
	var target_pos = next_cell.position
	var target_control = target_pos + Vector3(0.0, 0.5, 0.0)

	jump_time = 0.25
	var land_delay_time = 0.1
	if G.get_time() - last_move_time < land_delay_time:
		return

	var elapsed_time = clampf(jump_time - jump_time_remaining, 0.0, jump_time)
	var t = Tween.interpolate_value(0.0, 1.0, elapsed_time, jump_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	var jump_pos = G.get_bezier_position(origin_pos, origin_control, target_pos, target_control, t)
	global_position = jump_pos
	jump_time_remaining -= delta

	if t >= 0.5 and (not scale_tween or not scale_tween.is_running()):
		scale_tween = create_tween()
		var tween_time = (jump_time + land_delay_time) / 2.0
		scale_tween.tween_property(shape, "scale", Vector3(1.2, 0.8, 1.2), tween_time)
		scale_tween.tween_property(shape, "scale", Vector3.ONE, tween_time)

	if t >= 1.0:
		# Single frame land
		current_cell = next_cell
		last_move_time = G.get_time()
		jump_time_remaining = jump_time
		move_path_index += 1
		next_cell = _get_next_cell()
		if next_cell == null:
			state = EState.IDLE
			current_cell = move_path[-1]
			move_finished.emit()



func _create_debug_label() -> void:
	debug_label = Label3D.new()
	debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	debug_label.position.y = 1.0
	add_child(debug_label)


func _get_next_cell() -> CellData:
	if move_path.is_empty() or move_path_index + 1 >= move_path.size():
		return null
	return move_path[move_path_index + 1]


func _get_next_cell_auto() -> CellData:
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

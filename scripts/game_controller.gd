class_name GameController
extends Node

@export var cube_scene: PackedScene
@export var object_subviewport: SubViewport
@export var grid: Grid

var cube: Node3D
var runner: GridRunner
var hovered_cell: CellData
var selected_cell: CellData
var mouse_world_pos: Vector3


func _process(delta: float) -> void:
	if grid.is_grid_ready():
		_get_mouse_world_position()
		_get_cell_at_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if runner == null:
				_spawn_runner()
			else:
				_change_selected_cell(hovered_cell)
					


func _spawn_runner() -> void:
	if not grid.is_grid_ready():
		return
	runner = GridRunner.new()
	runner.grid = grid
	cube = cube_scene.instantiate() as Node3D
	runner.add_child(cube)
	runner.shape = cube
	grid.add_child(runner)
	runner.current_cell = hovered_cell
	runner.global_position = hovered_cell.position


func _change_selected_cell(new_cell: CellData) -> void:
	# state 1: no selected_cell, new_cell == null
	# state 2: no selected_cell, new_cell != selected_cell
	# state 3: selected_cell, new_cell == null
	# state 4: selected_cell, new_cell != selected_cell
	if selected_cell != null:
		_set_cell_selected_state(selected_cell, false)
		if new_cell == selected_cell or new_cell == null:
			selected_cell = null
			return

	if new_cell != null:
		_set_cell_selected_state(new_cell, true)

	selected_cell = new_cell


func _get_cell_at_mouse() -> void:
	var cell: CellData = grid.get_closest_cell_to_world_pos(mouse_world_pos)

	if cell != hovered_cell:
		if hovered_cell != null and hovered_cell != selected_cell:
			_set_cell_hovered_state(hovered_cell, false)
		if cell != null and cell != selected_cell:
			_set_cell_hovered_state(cell, true)

	hovered_cell = cell


func _set_cell_selected_state(cell: CellData, is_selected: bool) -> void:
	if is_selected:
		_set_grid_square_color(cell, Color.ORANGE)
		for adj_cell in cell.get_neighbor_cells():
			_set_grid_square_color(adj_cell, lerp(grid.line_color, Color.RED, 0.6), 0.0005)
	else:
		_reset_grid_square_color(cell)
		for adj_cell in cell.get_neighbor_cells():
			_reset_grid_square_color(adj_cell)


func _set_cell_hovered_state(cell: CellData, is_hovered: bool) -> void:
	if is_hovered:
		_set_grid_square_color(cell, lerp(grid.line_color, Color.ORANGE, 0.75))
	else:
		_reset_grid_square_color(cell)


func _reset_grid_square_color(cell: CellData) -> void:
	_set_grid_square_color(cell, grid.line_color)


func _set_grid_square_color(cell: CellData, color: Color, y_pos: float = 0.001) -> void:
	if color == grid.line_color:
		cell.grid_square.line_color = grid.line_color
		cell.grid_square.position.y = 0.0
		cell.grid_square.scale = Vector3.ONE
	else:
		cell.grid_square.line_color = color
		cell.grid_square.position.y = y_pos
		cell.grid_square.scale = Vector3.ONE * 1.02


func _get_mouse_world_position() -> void:
	var result = G.cam_mouse_raycast()
	if result:
		mouse_world_pos = result.position

class_name GameController
extends Node

@export var cube_scene: PackedScene
@export var basic_enemy_scene: PackedScene
@export var object_subviewport: SubViewport
@export var grid: Grid

var cube: Node3D
var mouse_world_pos: Vector3
var hovered_cell: CellData
var selected_cell: CellData

var last_hovered_cell: CellData
var move_preview_cell_path: Array[CellData]

var player_units: Array[TileUnit]
var enemy_units: Array[TileUnit]


func _ready() -> void:
	grid.setup_finished.connect(_on_grid_setup_finished)


func _process(delta: float) -> void:
	if grid.is_grid_ready():
		_get_mouse_world_position()
		_get_cell_at_mouse()

	# if selected_cell:
	# 	_process_selected_cell(delta)

	var selected_unit = _get_selected_unit()
	DebugDraw2D.set_text("Selected Unit", selected_unit)

	if _is_player_unit_selected():
		_process_runner_move_select()
	elif not move_preview_cell_path.is_empty():
		move_preview_cell_path.clear()

	last_hovered_cell = hovered_cell


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if _is_player_unit_selected() and not move_preview_cell_path.is_empty():
				var unit = _get_selected_unit()
				unit.unit.move(move_preview_cell_path)
				_change_selected_cell(move_preview_cell_path[-1])
			elif hovered_cell and hovered_cell != selected_cell:
				_change_selected_cell(hovered_cell)
			else:
				_change_selected_cell(null)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			var unit = _get_selected_unit()
			if unit != null and unit.unit.can_move():
				_change_selected_cell(null)
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_released():
			var unit = _get_selected_unit()
			if unit != null and unit.unit.can_move():
				_change_selected_cell(null)


func _is_player_unit_selected() -> bool:
	var selected_unit = _get_selected_unit()
	if selected_unit == null:
		return false
	return selected_unit.is_player()
	# return selected_cell != null and selected_cell == runner.current_cell and runner.can_move()


func _get_selected_unit() -> TileUnit:
	return _get_selected_occupant() as TileUnit


func _get_selected_occupant() -> TileOccupant:
	if not _is_occupant_selected():
		return null
	return selected_cell.occupant


func _is_unit_selected() -> bool:
	if selected_cell == null:
		return false
	return selected_cell.occupant is TileUnit


func _is_occupant_selected() -> bool:
	if selected_cell == null:
		return false
	return selected_cell.occupant != null


func _calculate_unit_move_path(unit: TileUnit) -> void:
	if hovered_cell != null and hovered_cell != unit.cell:
		move_preview_cell_path = grid.get_cell_path(unit.cell, hovered_cell)


func _process_runner_move_select() -> void:
	var selected_unit = _get_selected_unit()
	if selected_unit == null:
		return
	if not selected_unit.is_player():
		return
	if not selected_unit.unit.can_move():
		return

	if hovered_cell != last_hovered_cell:
		_calculate_unit_move_path(selected_unit)
	
	if hovered_cell == null or hovered_cell == selected_unit.cell:
		move_preview_cell_path.clear()

	GridUtils.draw_cell_path(move_preview_cell_path)


func _process_selected_cell(_delta: float) -> void:
	if hovered_cell != null and hovered_cell != last_hovered_cell and hovered_cell != selected_cell:
		move_preview_cell_path = grid.get_cell_path(selected_cell, hovered_cell)
	
	if hovered_cell == null or hovered_cell == selected_cell:
		move_preview_cell_path.clear()

	GridUtils.draw_cell_path(move_preview_cell_path)
	

func _change_selected_cell(new_cell: CellData) -> void:
	if selected_cell != null:
		_set_cell_selected_state(selected_cell, false)
		if new_cell == selected_cell or new_cell == null:
			selected_cell = null
			return

	if new_cell != null:
		_set_cell_selected_state(new_cell, true)

	selected_cell = new_cell

	if _is_player_unit_selected():
		grid.update_astar_availability_for_player()


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
		# for adj_cell in cell.get_neighbor_cells():
		# 	_set_grid_square_color(adj_cell, lerp(grid.line_color, Color.RED, 0.6), 0.0005)
	else:
		_reset_grid_square_color(cell)
		# for adj_cell in cell.get_neighbor_cells():
		# 	_reset_grid_square_color(adj_cell)


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


func _can_add_unit_to_grid(coord: Vector2i) -> bool:
	var cell: CellData = grid.grid_to_cell(coord)
	return cell.occupant == null


func _create_runner() -> GridRunner:
	var new_runner = GridRunner.new()
	new_runner.grid = grid
	return new_runner


func _create_player_unit() -> TileUnit:
	var new_runner = _create_runner()
	cube = cube_scene.instantiate() as Node3D
	new_runner.add_child(cube)
	new_runner.shape = cube
	return TileUnit.new(TileUnit.EType.PLAYER, new_runner)


func _create_enemy_unit() -> TileUnit:
	var new_runner = _create_runner()
	var enemy = basic_enemy_scene.instantiate() as Node3D
	new_runner.add_child(enemy)
	new_runner.shape = enemy
	return TileUnit.new(TileUnit.EType.ENEMY, new_runner)


func _create_player_units() -> void:
	var player_unit: TileUnit = _create_player_unit()
	_add_unit_to_grid(player_unit, Vector2i(4, 0))


func _create_enemy_units() -> void:
	var enemy_unit: TileUnit = _create_enemy_unit()
	_add_unit_to_grid(enemy_unit, Vector2i(4, 4))


func _add_unit_to_grid(unit: TileUnit, coord: Vector2i) -> void:
	assert(grid.is_cell_available(coord))
	var spawn_cell: CellData = grid.grid_to_cell(coord)
	var grid_runner: GridRunner = unit.unit
	grid_runner.move_finished.connect(_on_grid_runner_move_finished.bind(unit))
	grid_runner.cell_changed.connect(_on_grid_runner_cell_changed.bind(unit))
	grid_runner.current_cell = spawn_cell
	spawn_cell.occupant = unit
	grid.add_child(grid_runner)
	grid_runner.snap_to_current_cell()


func _on_grid_setup_finished() -> void:
	_create_player_units()
	_create_enemy_units()


func _on_grid_runner_cell_changed(prev_cell: CellData, new_cell: CellData, unit: TileUnit) -> void:
	if prev_cell != null and prev_cell.occupant == unit:
		prev_cell.occupant = null
	new_cell.occupant = unit


func _on_grid_runner_move_finished(unit: TileUnit) -> void:
	_calculate_unit_move_path(unit)
	grid.update_astar_availability_for_player()

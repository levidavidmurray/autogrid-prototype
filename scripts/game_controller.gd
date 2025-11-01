class_name GameController
extends Node

enum PlayerUnitState {
	NOT_SELECTED,
	MOVE_PREVIEW,
	ABILITY_PREVIEW
}

@export var cube_scene: PackedScene
@export var basic_enemy_scene: PackedScene
@export var grid: Grid
@export var health_bar_ui_scene: PackedScene
@export var camera: Camera3D

var player_unit_state: PlayerUnitState:
	set(value):
		if value == player_unit_state:
			return
		var prev = player_unit_state
		player_unit_state = value
		_handle_player_unit_state_change(prev, value)

var player_units: Array[TileUnit]
var enemy_units: Array[TileUnit]

var mouse_world_pos: Vector3
var hovered_cell: CellData
var selected_cell: CellData

var last_hovered_cell: CellData
var move_preview_cell_path: Array[CellData] # TODO: Remove?
var preview_ability: AbstractAbility
var preview_ability_target_cells: Array[CellData]
var show_all_ui_data: bool = false

var health_bar_ui: HealthBarUI

var occupant_id_health_bar_map: Dictionary[String, HealthBarUI]
var unit_id_valid_moves_map: Dictionary[String, Array] # Dictionary[String, Array[CellData]]


func _ready() -> void:
	grid.setup_finished.connect(_on_grid_setup_finished)


func _process(delta: float) -> void:
	if not grid.is_grid_ready():
		return

	_get_mouse_world_position()
	_get_cell_at_mouse()

	_process_selected_cell_state()
	_process_player_unit_state()
	_process_cell_hover()

	last_hovered_cell = hovered_cell


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			if _is_player_unit_selected():
				_handle_player_unit_hovered_cell_click()
			elif hovered_cell and hovered_cell != selected_cell:
				_change_selected_cell(hovered_cell)
			else:
				_change_selected_cell(null)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_released():
			_change_selected_cell(null)
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_released():
			_change_selected_cell(null)
		if event.keycode == KEY_1 and event.is_released():
			var player_unit = player_units[0]
			preview_ability = player_unit.abilities[0]
		if event.keycode == KEY_ALT:
			show_all_ui_data = event.is_pressed()
		if event.keycode == KEY_P and event.is_released():
			var enemy_unit = enemy_units[0]
			if not enemy_unit.can_move:
				return
			var player_unit = player_units[0]
			_enemy_chase_player(enemy_unit, player_unit)


func _change_selected_cell(new_cell: CellData) -> void:
	if _is_player_unit_selected():
		for cell: CellData in unit_id_valid_moves_map[_get_selected_unit().id]:
			cell.grid_square.is_moveable = false

	if selected_cell != null:
		_set_cell_selected_state(selected_cell, false)
		if new_cell == selected_cell or new_cell == null:
			selected_cell = null
			return

	if new_cell != null:
		_set_cell_selected_state(new_cell, true)

	selected_cell = new_cell

	if _is_player_unit_selected():
		_calculate_valid_moves_for_unit(_get_selected_unit())


func _handle_player_unit_hovered_cell_click() -> void:
	var player_unit = _get_selected_unit()
	var target_cell: CellData = hovered_cell

	if player_unit_state == PlayerUnitState.MOVE_PREVIEW:
		if not move_preview_cell_path.is_empty():
			var final_cell = move_preview_cell_path[-1]
			_change_selected_cell(null)
			await NavigatePathAction.create(player_unit, move_preview_cell_path)
			_calculate_unit_move_path(player_unit, final_cell)
			return

		if target_cell == selected_cell:
			_change_selected_cell(null)
		else:
			_change_selected_cell(target_cell)
		return

	if player_unit_state == PlayerUnitState.ABILITY_PREVIEW:
		# Check if clicked cell is in possible cells for previewed ability
		var can_execute = AbilityHelper.can_target_cell(preview_ability, player_unit.cell, target_cell)
		if can_execute:
			preview_ability.execute(player_unit, target_cell)
		preview_ability = null
		_change_selected_cell(null)


func _enemy_chase_player(enemy_unit: TileUnit, player_unit: TileUnit) -> void:
	var target_cells: Array[CellData] = player_unit.cell.get_neighbor_cells()
	var target_cell: CellData = null
	while target_cell == null and not target_cells.is_empty():
		var cell = target_cells[randi_range(0, target_cells.size()-1)]
		if cell.occupant != null:
			target_cells.erase(cell)
			continue
		target_cell = cell
		break
	grid.update_astar_availability_for_enemy()
	var cell_path = grid.get_cell_path(enemy_unit.cell, target_cell)
	await NavigatePathAction.create(enemy_unit, cell_path)


func _process_cell_hover() -> void:
	# TODO: Change when we have an array of all occupants
	_process_health_bars(player_units)
	_process_health_bars(enemy_units)


func _process_health_bars(units: Array[TileUnit]) -> void:
	for unit in units:
		var health_bar = occupant_id_health_bar_map[unit.id]
		health_bar.hide()
		var should_show_health_bar = hovered_cell != null and unit == hovered_cell.occupant
		if should_show_health_bar or show_all_ui_data:
			health_bar.show()
			health_bar.max_health = unit.health.max_health
			health_bar.current_health = unit.health.current_health
			health_bar.scale = Vector2.ONE
			var health_bar_pos = unit.body.global_position
			health_bar_pos.y += 0.95
			var pos_2d = camera.unproject_position(health_bar_pos)
			pos_2d.x -= (health_bar.size.x * health_bar.scale.x) / 2.0
			health_bar.global_position = pos_2d


func _process_selected_cell_state() -> void:
	if selected_cell == null:
		return
	DebugDraw2D.set_text("Cell", selected_cell, 0)
	var occupant = selected_cell.occupant
	if occupant == null:
		return
	DebugDraw2D.set_text("Occupant", occupant, 1)
	DebugDraw2D.set_text("Health", occupant.health.get_health_string(), 2)


func _handle_player_unit_state_change(prev: PlayerUnitState, new: PlayerUnitState) -> void:
	var selected_unit = _get_selected_unit()

	if new == PlayerUnitState.ABILITY_PREVIEW:
		preview_ability_target_cells = AbilityHelper.get_possible_target_cells(preview_ability, selected_unit.cell)
		for cell in preview_ability_target_cells:
			cell.grid_square.is_targeted = true

	if prev == PlayerUnitState.ABILITY_PREVIEW:
		for cell in preview_ability_target_cells:
			cell.grid_square.is_targeted = false
		preview_ability_target_cells.clear()


func _check_player_unit_state_change() -> void:
	if not _is_player_unit_selected():
		player_unit_state = PlayerUnitState.NOT_SELECTED
		preview_ability = null
		return
	if preview_ability == null:
		player_unit_state = PlayerUnitState.MOVE_PREVIEW
	else:
		player_unit_state = PlayerUnitState.ABILITY_PREVIEW


func _process_player_unit_state() -> void:
	_check_player_unit_state_change()

	match player_unit_state:
		PlayerUnitState.NOT_SELECTED:
			_process_player_unit_state_not_selected()
		PlayerUnitState.MOVE_PREVIEW:
			_process_player_unit_state_move_preview()
		PlayerUnitState.ABILITY_PREVIEW:
			_process_player_unit_state_ability_preview()


func _process_player_unit_state_not_selected() -> void:
	if not move_preview_cell_path.is_empty():
		move_preview_cell_path.clear()


func _process_player_unit_state_move_preview() -> void:
	var selected_unit = _get_selected_unit()
	if not selected_unit.can_move:
		return

	if hovered_cell != last_hovered_cell:
		_calculate_unit_move_path(selected_unit, hovered_cell)

	if not unit_id_valid_moves_map.has(selected_unit.id):
		_calculate_valid_moves_for_unit(selected_unit)

	for cell: CellData in unit_id_valid_moves_map[selected_unit.id]:
		cell.grid_square.is_moveable = true

	# GridUtils.draw_cells(unit_id_valid_moves_map[selected_unit.id])
	
	# TODO: Remove move_preview_cell_path?
	if hovered_cell == null or hovered_cell == selected_unit.cell:
		move_preview_cell_path.clear()

	# GridUtils.draw_cell_path(move_preview_cell_path)


func _process_player_unit_state_ability_preview() -> void:
	DebugDraw2D.set_text("Ability Preview", preview_ability)
	for cell: CellData in unit_id_valid_moves_map[_get_selected_unit().id]:
		cell.grid_square.is_moveable = false


func _is_player_unit_selected() -> bool:
	var selected_unit = _get_selected_unit()
	if selected_unit == null:
		return false
	return selected_unit.is_player()


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


func _calculate_unit_move_path(unit: TileUnit, cell: CellData) -> void:
	move_preview_cell_path.clear()
	if cell == null or cell == unit.cell:
		return
	if not unit.can_move or not unit.is_cell_in_move_range(cell):
		return
	move_preview_cell_path = grid.get_cell_path(unit.cell, cell)


func _calculate_valid_moves_for_unit(unit: TileUnit) -> void:
	var cells_in_range = Grid.instance.get_cells_n_units(unit.cell, unit.max_move_distance, true)
	Grid.instance.update_astar_availability_for_unit(unit)
	if not unit_id_valid_moves_map.has(unit.id):
		unit_id_valid_moves_map[unit.id] = []
	var valid_cells = unit_id_valid_moves_map[unit.id]
	valid_cells.clear()
	# Need to calculate A-star length for each coord
	for cell in cells_in_range:
		var path = Grid.instance.get_cell_path(unit.cell, cell)
		if path.size() - 1 <= unit.max_move_distance:
			valid_cells.append(cell)


func _get_cell_at_mouse() -> void:
	var cell: CellData = grid.get_closest_cell_to_world_pos(mouse_world_pos)

	if cell != hovered_cell:
		if hovered_cell != null:
			_set_cell_hovered_state(hovered_cell, false)
		if cell != null:
			_set_cell_hovered_state(cell, true)

	hovered_cell = cell


func _set_cell_selected_state(cell: CellData, is_selected: bool) -> void:
	cell.grid_square.is_selected = is_selected


func _set_cell_hovered_state(cell: CellData, is_hovered: bool) -> void:
	cell.grid_square.is_hovered = is_hovered


func _get_mouse_world_position() -> void:
	var result = G.cam_mouse_raycast()
	if result:
		mouse_world_pos = result.position


func _can_add_unit_to_grid(coord: Vector2i) -> bool:
	var cell: CellData = grid.grid_to_cell(coord)
	return cell.occupant == null


func _create_player_unit() -> TileUnit:
	var player_body = cube_scene.instantiate() as Node3D
	return TileUnit.new(TileUnit.EType.PLAYER, player_body)


func _create_enemy_unit() -> TileUnit:
	var enemy_body = basic_enemy_scene.instantiate() as Node3D
	return TileUnit.new(TileUnit.EType.ENEMY, enemy_body)


func _create_player_units() -> void:
	var player_unit: TileUnit = _create_player_unit()
	player_unit.can_move = true
	_add_unit_to_grid(player_unit, Vector2i(4, 0))
	var strike_ability = StrikeAbility.new()
	player_unit.abilities.append(strike_ability)
	player_units.append(player_unit)


func _create_enemy_units() -> void:
	var enemy_unit: TileUnit = _create_enemy_unit()
	enemy_unit.can_move = true
	enemy_unit.health.set_max_health(4)
	_add_unit_to_grid(enemy_unit, Vector2i(4, 4))
	enemy_units.append(enemy_unit)


func _add_unit_to_grid(unit: TileUnit, coord: Vector2i) -> void:
	assert(grid.is_cell_available(coord))
	var spawn_cell: CellData = grid.grid_to_cell(coord)

	var health_bar: HealthBarUI = health_bar_ui_scene.instantiate()
	occupant_id_health_bar_map[unit.id] = health_bar
	add_child(health_bar)
	health_bar.max_health = unit.health.max_health
	health_bar.current_health = unit.health.current_health

	unit.cell_changed.connect(_on_unit_cell_changed.bind(unit))
	unit.health.current_health_changed.connect(_on_tile_occupant_health_changed.bind(unit))
	unit.health.died.connect(_on_tile_occupant_died.bind(unit))

	# TODO: Figure out what's happening with GridRunner current_cell and CellData occupant setters
	# grid_runner.current_cell = spawn_cell
	grid.add_child(unit.body)
	grid.set_cell_occupant(spawn_cell, unit)


func _on_grid_setup_finished() -> void:
	_create_player_units()
	_create_enemy_units()


func _on_tile_occupant_health_changed(prev_health: int, new_health: int, occupant: TileOccupant) -> void:
	Log.debug("%s health changed %s->%s" % [occupant, prev_health, new_health])
	if occupant_id_health_bar_map.has(occupant.id):
		var health_bar: HealthBarUI = occupant_id_health_bar_map[occupant.id]
		health_bar.current_health = occupant.health.current_health


func _on_tile_occupant_died(occupant: TileOccupant) -> void:
	Log.info("%s died" % occupant)


func _on_unit_cell_changed(_prev: CellData, _new: CellData, unit: TileUnit) -> void:
	_calculate_valid_moves_for_unit(unit)

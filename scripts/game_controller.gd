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

var player_unit_state: PlayerUnitState
var ability_helper: AbilityHelper
var player_units: Array[TileUnit]
var enemy_units: Array[TileUnit]

var mouse_world_pos: Vector3
var hovered_cell: CellData
var selected_cell: CellData

var last_hovered_cell: CellData
var move_preview_cell_path: Array[CellData]
var preview_ability: Ability
var show_all_ui_data: bool = false

var health_bar_ui: HealthBarUI

var occupant_id_health_bar_map: Dictionary[String, HealthBarUI]



func _ready() -> void:
	grid.setup_finished.connect(_on_grid_setup_finished)
	ability_helper = AbilityHelper.new(grid)


func _process(delta: float) -> void:
	if not grid.is_grid_ready():
		return

	_get_mouse_world_position()
	_get_cell_at_mouse()

	if not player_units.is_empty():
		var player = player_units[0]
		DebugDraw2D.set_text("player.can_move", player.can_move)
	if not enemy_units.is_empty():
		var enemy = enemy_units[0]
		DebugDraw2D.set_text("enemy.can_move", enemy.can_move)

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
			var unit = _get_selected_unit()
			if unit != null and unit.can_move:
				_change_selected_cell(null)
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_released():
			var unit = _get_selected_unit()
			if unit != null and unit.can_move:
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


func _handle_player_unit_hovered_cell_click() -> void:
	var player_unit = _get_selected_unit()
	var target_cell: CellData = hovered_cell

	if player_unit_state == PlayerUnitState.MOVE_PREVIEW:
		if not move_preview_cell_path.is_empty():
			# player_unit.unit.move(move_preview_cell_path)
			# _handle_unit_move(player_unit, move_preview_cell_path)
			NavigatePathAction.create(player_unit, move_preview_cell_path)
			_change_selected_cell(move_preview_cell_path[-1])
		else:
			if target_cell == selected_cell:
				_change_selected_cell(null)
			else:
				_change_selected_cell(target_cell)
		return

	if player_unit_state == PlayerUnitState.ABILITY_PREVIEW:
		# Check if clicked cell is in possible cells for previewed ability
		var can_execute = ability_helper.can_target_cell(preview_ability, player_unit.cell, target_cell)
		if can_execute:
			StrikeAction.create(player_unit, target_cell)
			# ability_helper.execute(preview_ability, player_unit, target_cell)
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
			if unit.is_player():
				# health_bar.max_health = 5
				DebugDraw2D.set_text(unit.to_string(), health_bar.custom_minimum_size)


func _process_selected_cell_state() -> void:
	if selected_cell == null:
		return
	DebugDraw2D.set_text("Cell", selected_cell, 0)
	var occupant = selected_cell.occupant
	if occupant == null:
		return
	DebugDraw2D.set_text("Occupant", occupant, 1)
	DebugDraw2D.set_text("Health", occupant.health.get_health_string(), 2)
	


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
		_calculate_unit_move_path(selected_unit)
	
	if hovered_cell == null or hovered_cell == selected_unit.cell:
		move_preview_cell_path.clear()

	GridUtils.draw_cell_path(move_preview_cell_path)


func _process_player_unit_state_ability_preview() -> void:
	DebugDraw2D.set_text("Ability Preview", preview_ability)
	var selected_unit = _get_selected_unit()
	var target_cells = ability_helper.get_possible_target_cells(preview_ability, selected_unit.cell)
	GridUtils.draw_cells(target_cells, Color.RED)


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


func _calculate_unit_move_path(unit: TileUnit) -> void:
	if hovered_cell != null and hovered_cell != unit.cell:
		move_preview_cell_path = grid.get_cell_path(unit.cell, hovered_cell)


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
	var strike_ability = AbilityManager.get_ability_by_name("Strike")
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

	unit.health.current_health_changed.connect(_on_tile_occupant_health_changed.bind(unit))
	unit.health.died.connect(_on_tile_occupant_died.bind(unit))

	# TODO: Figure out what's happening with GridRunner current_cell and CellData occupant setters
	# grid_runner.current_cell = spawn_cell
	grid.add_child(unit.body)
	grid.set_cell_occupant(spawn_cell, unit)


func _on_grid_setup_finished() -> void:
	_create_player_units()
	_create_enemy_units()


func _on_grid_runner_move_finished(unit: TileUnit) -> void:
	_calculate_unit_move_path(unit)
	grid.update_astar_availability_for_player()


func _on_tile_occupant_health_changed(prev_health: int, new_health: int, occupant: TileOccupant) -> void:
	Log.debug("%s health changed %s->%s" % [occupant, prev_health, new_health])
	if occupant_id_health_bar_map.has(occupant.id):
		var health_bar: HealthBarUI = occupant_id_health_bar_map[occupant.id]
		health_bar.current_health = occupant.health.current_health


func _on_tile_occupant_died(occupant: TileOccupant) -> void:
	Log.info("%s died" % occupant)

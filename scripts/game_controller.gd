class_name GameController
extends Node

@export var cube_scene: PackedScene
@export var object_subviewport: SubViewport
@export var grid: Grid

var cube: Node3D
var runner: GridRunner
var hovered_cell: CellData
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
				if hovered_cell != null:
					runner.current_cell = hovered_cell


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



func _get_cell_at_mouse() -> void:
	var cell: CellData = grid.get_closest_cell_to_world_pos(mouse_world_pos)

	if cell != hovered_cell:
		if hovered_cell:
			hovered_cell.grid_square.line_color = grid.line_color
			hovered_cell.grid_square.position.y = 0.0
			hovered_cell.grid_square.scale = Vector3.ONE
		if cell:
			cell.grid_square.line_color = lerp(grid.line_color, Color.ORANGE, 0.75)
			cell.grid_square.position.y = 0.001
			cell.grid_square.scale = Vector3.ONE * 1.02

	hovered_cell = cell


func _get_mouse_world_position() -> void:
	var result = G.cam_mouse_raycast()
	if result:
		mouse_world_pos = result.position

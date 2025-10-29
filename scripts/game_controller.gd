class_name GameController
extends Node

@export var cube_scene: PackedScene
@export var object_subviewport: SubViewport
@export var grid: Grid

var cube: Node3D
var runner: GridRunner
var hovered_cell: Vector2i = Vector2i(-1, -1)
var mouse_world_pos: Vector3

var has_hovered_cell: bool:
	get:
		return hovered_cell != Vector2i(-1, -1)

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
				if has_hovered_cell:
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
	runner.global_position = grid.grid_to_world(hovered_cell)



func _get_cell_at_mouse() -> void:
	var cell = grid.world_to_grid(mouse_world_pos)

	var grid_square: GridSquare
	if cell != hovered_cell:
		if grid.grid_squares.has(hovered_cell):
			grid_square = grid.grid_squares[hovered_cell]
			grid_square.line_color = grid.line_color
			grid_square.position.y = 0.0
			grid_square.scale = Vector3.ONE
		if grid.grid_squares.has(cell):
			grid_square = grid.grid_squares[cell]
			grid_square.line_color = lerp(grid.line_color, Color.ORANGE, 0.75)
			grid_square.position.y = 0.001
			grid_square.scale = Vector3.ONE * 1.02


	hovered_cell = cell


func _get_mouse_world_position() -> void:
	var result = G.cam_mouse_raycast()
	if result:
		mouse_world_pos = result.position

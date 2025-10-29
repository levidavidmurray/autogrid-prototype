@tool
class_name Grid
extends Node3D

@export var grid_square_scene: PackedScene
@export var grid_size: Vector2i = Vector2i(10, 10):
	set(value):
		grid_size = value
		is_grid_dirty = true

@export var cell_size: float = 1.0:
	set(value):
		cell_size = value
		is_grid_dirty = true

@export var base_color: Color = Color("18243d"):
	set(value):
		base_color = value
		is_squares_dirty = true

@export var line_color: Color = Color.WHITE:
	set(value):
		line_color = value
		is_squares_dirty = true

@export var line_width: float = 0.02:
	set(value):
		line_width = value
		is_squares_dirty = true

var is_grid_dirty = true
var is_squares_dirty = true

var grid_coords: Array[Array]
var grid_outline_coords: Array[Array]
var grid_squares: Dictionary[Vector2i, GridSquare]

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if is_grid_dirty:
		_generate_grid()
		is_grid_dirty = false
	if is_squares_dirty:
		_update_grid_squares()
		is_squares_dirty = false

	# _process_grid_debug(delta)


func is_grid_ready() -> bool:
	return not grid_squares.is_empty()


func grid_to_world(cell_coord: Vector2i) -> Vector3:
	assert(cell_coord.x < grid_size.x, "[world_to_grid] cell_coord.x must be smaller than grid_size.x")
	assert(cell_coord.y < grid_size.y, "[world_to_grid] cell_coord.y must be smaller than grid_size.y")
	return grid_coords[cell_coord.y][cell_coord.x]


func world_to_grid(world_pos: Vector3) -> Vector2i:
	var closest_grid_pos: Vector2i = Vector2i(-1, -1)
	var closest_sq_dist: float = ((cell_size + line_width) * 1.41) / 2.0
	for y in range(grid_coords.size()):
		var row = grid_coords[y]
		for x in range(row.size()):
			var cell_pos: Vector3 = row[x]
			var sq_dist = cell_pos.distance_squared_to(world_pos)
			if sq_dist < closest_sq_dist:
				closest_sq_dist = sq_dist
				closest_grid_pos = Vector2i(x, y)
	return closest_grid_pos


func _process_grid_debug(_delta: float) -> void:
	var config = DebugDraw3D.new_scoped_config()
	config.set_thickness(0.015)
	for i in range(grid_coords.size()):
		var row = grid_coords[i]
		for j in range(row.size()):
			DebugDraw3D.draw_sphere(row[j], 0.025, Color.WHITE)

	for i in range(grid_outline_coords.size()):
		var row = grid_outline_coords[i]

		for j in range(row.size()):
			if i == 0:
				var last_row = grid_outline_coords[-1]
				var col_last = last_row[j]
				DebugDraw3D.draw_line(row[j], col_last, Color.WHITE)

			# DebugDraw3D.draw_sphere(row[j], 0.025, Color.ORANGE)

		var row_first = row[0]
		var row_last = row[-1]
		DebugDraw3D.draw_line(row_first, row_last, Color.WHITE)


func _update_grid_squares() -> void:
	for cell in grid_squares:
		var grid_square: GridSquare = grid_squares[cell]
		grid_square.cell_size = cell_size
		grid_square.base_color = base_color
		grid_square.line_color = line_color
		grid_square.line_width = line_width


func _create_grid_squares() -> void:
	for child in get_children():
		if child is GridSquare:
			child.queue_free()
	grid_squares.clear()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell = Vector2i(x, y)
			var grid_square = grid_square_scene.instantiate() as GridSquare
			add_child(grid_square)
			grid_square.global_position = grid_to_world(cell)
			grid_squares[cell] = grid_square
	_update_grid_squares()


func _generate_grid() -> void:
	grid_coords.clear()
	for z in range(grid_size.y):
		var row: Array[Vector3] = []
		row.resize(grid_size.x)
		for x in range(grid_size.x):
			row[x] = Vector3(x * cell_size, 0.0, z * cell_size)
		grid_coords.append(row)

	grid_outline_coords.clear()
	for z in range(grid_size.y + 1):
		var outline_row: Array[Vector3] = []
		outline_row.resize(grid_size.x + 1)
		for x in range(outline_row.size()):
			var half_cell_size = cell_size / 2.0
			outline_row[x] = Vector3((x * cell_size) - half_cell_size, 0.0, (z * cell_size) - half_cell_size)
		grid_outline_coords.append(outline_row)
	
	_create_grid_squares()

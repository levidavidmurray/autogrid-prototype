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

var cells: Array # Array[Array[CellData]]


func _process(delta: float) -> void:
	if is_grid_dirty:
		_generate_grid()
		is_grid_dirty = false
	if is_squares_dirty:
		_update_grid_squares()
		is_squares_dirty = false


func is_grid_ready() -> bool:
	return not cells.is_empty()


func is_valid_coord(coord: Vector2i) -> bool:
	if coord.x >= grid_size.x:
		return false
	if coord.y >= grid_size.y:
		return false
	if grid_to_cell(coord) == null:
		return false
	return true


func grid_to_world(coord: Vector2i) -> Vector3:
	var cell: CellData = grid_to_cell(coord)
	assert(cell != null, "CellData at coord %s == null" % coord)
	return cell.position


func grid_to_cell(coord: Vector2i) -> CellData:
	assert(coord.x < grid_size.x, "[grid_to_cell] coord.x must be smaller than grid_size.x")
	assert(coord.y < grid_size.y, "[grid_to_cell] coord.y must be smaller than grid_size.y")
	return cells[coord.y][coord.x]


func world_to_grid(world_pos: Vector3) -> Vector2i:
	var grid_pos: Vector2i = Vector2i(-1, -1)
	var closest_cell = get_closest_cell_to_world_pos(world_pos)
	if closest_cell:
		grid_pos = closest_cell.coord
	return grid_pos


func get_closest_cell_to_world_pos(world_pos: Vector3) -> CellData:
	var closest_cell: CellData = null
	var closest_sq_dist: float = ((cell_size + line_width) * 1.41) / 2.0
	for y in range(cells.size()):
		for x in range(cells[y].size()):
			var cell: CellData = cells[y][x]
			var sq_dist = cell.position.distance_squared_to(world_pos)
			if sq_dist < closest_sq_dist:
				closest_sq_dist = sq_dist
				closest_cell = cell
	return closest_cell


func _update_grid_squares() -> void:
	ArrayUtils.for_2d_array(cells, func(cell: CellData):
		cell.grid_square.cell_size = cell_size
		cell.grid_square.base_color = base_color
		cell.grid_square.line_color = line_color
		cell.grid_square.line_width = line_width
	)


func _generate_grid() -> void:
	ArrayUtils.for_2d_array(cells, func(cell: CellData):
		cell.grid_square.queue_free()
	)
	cells.clear()

	cells = ArrayUtils.create_2d_array(grid_size)
	ArrayUtils.for_2d_array(cells, func(x: int, y: int):
		var cell_world_pos = Vector3(x * cell_size, 0.0, y * cell_size)

		var grid_square = grid_square_scene.instantiate() as GridSquare
		add_child(grid_square)
		grid_square.global_position = cell_world_pos

		var cell = CellData.new(Vector2i(x, y))
		cell.position = cell_world_pos
		cell.grid_square = grid_square
		cells[y][x] = cell
	)

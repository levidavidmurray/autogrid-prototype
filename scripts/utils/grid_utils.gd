class_name GridUtils

enum ECardinalDirection { NORTH, EAST, SOUTH, WEST }

const CARDINAL_DIRECTIONS: Array[ECardinalDirection] = [
	ECardinalDirection.NORTH,
	ECardinalDirection.EAST,
	ECardinalDirection.SOUTH,
	ECardinalDirection.WEST,
]

const CARDINAL_VEC2I_MAP: Dictionary[ECardinalDirection, Vector2i] = {
	ECardinalDirection.NORTH: Vector2i.DOWN,
	ECardinalDirection.EAST: Vector2i.LEFT,
	ECardinalDirection.SOUTH: Vector2i.UP,
	ECardinalDirection.WEST: Vector2i.RIGHT,
}

const VEC2I_CARDINAL_MAP: Dictionary[Vector2i, ECardinalDirection] = {
	Vector2i.DOWN: ECardinalDirection.NORTH,
	Vector2i.LEFT: ECardinalDirection.EAST,
	Vector2i.UP: ECardinalDirection.SOUTH,
	Vector2i.RIGHT: ECardinalDirection.WEST,
}

static func cardinal_to_vec2i(direction: ECardinalDirection) -> Vector2i:
	return CARDINAL_VEC2I_MAP[direction]


static func vec2i_to_cardinal(direction: Vector2i) -> ECardinalDirection:
	var clamped_dir := direction.clampi(-1, 1)
	assert(VEC2I_CARDINAL_MAP.has(clamped_dir), "[GridUtils::vec2i_to_cardinal] direction (%s) must be normalized to cardinal direction" % direction)
	return VEC2I_CARDINAL_MAP[clamped_dir]


static func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


static func print_cell_path(cell_path: Array[CellData]) -> void:
	var path_str = ""
	for i in range(cell_path.size()):
		var cell: CellData = cell_path[i]
		if i == cell_path.size() - 1:
			path_str += str(cell.coord)
		else:
			path_str += "%s->" % str(cell.coord)
	print(path_str)


static func draw_cell_path(cell_path: Array[CellData]) -> void:
	if cell_path.size() < 2:
		return
	var point_path: PackedVector3Array = PackedVector3Array()
	for cell in cell_path:
		point_path.append(cell.position)
	DebugDraw3D.draw_line_path(point_path)


# cell: Array[CellData]
static func draw_cells(cells: Array, color: Color = Color.GREEN) -> void:
	for cell in cells:
		var grid_square: GridSquare = cell.grid_square
		var box_size = Vector3.ONE * grid_square.cell_size
		box_size /= 1.5
		box_size.y /= 5.0
		DebugDraw3D.draw_box(cell.position, Quaternion(), box_size, color, true)

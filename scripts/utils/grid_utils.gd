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
	var clamped_dir := direction.clampi(0, 1)
	assert(VEC2I_CARDINAL_MAP.has(clamped_dir), "[GridUtils::vec2i_to_cardinal] direction (%s) must be normalized to cardinal direction" % direction)
	return VEC2I_CARDINAL_MAP[clamped_dir]

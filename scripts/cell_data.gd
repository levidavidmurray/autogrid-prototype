class_name CellData
extends RefCounted

var id: int = -1 # Flattened array index used for AStar2D
var coord: Vector2i
var position: Vector3
var grid_square: GridSquare
var occupant: Node3D
var neighbor_map: Dictionary[GridUtils.ECardinalDirection, CellData]


func _init(_coord: Vector2i):
	self.coord = _coord


func get_neighbor_cells() -> Array[CellData]:
	var neighbors: Array[CellData] = []
	neighbors.assign(neighbor_map.values().filter(func(c): return c != null))
	return neighbors


func print_neighbors() -> void:
	print("[%s] neighbors: NORTH: %s, EAST: %s, SOUTH: %s, WEST: %s" % [
		self,
		neighbor_map[GridUtils.ECardinalDirection.NORTH],
		neighbor_map[GridUtils.ECardinalDirection.EAST],
		neighbor_map[GridUtils.ECardinalDirection.SOUTH],
		neighbor_map[GridUtils.ECardinalDirection.WEST],
	])


func _to_string() -> String:
	return "CellData { coords(%s, %s) }" % [coord.x, coord.y]
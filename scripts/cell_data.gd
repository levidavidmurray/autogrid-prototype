class_name CellData
extends RefCounted

var coord: Vector2i
var position: Vector3
var grid_square: GridSquare
var occupant: Node3D

func _init(_coord: Vector2i):
    self.coord = _coord

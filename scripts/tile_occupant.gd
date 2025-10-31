class_name TileOccupant
extends RefCounted

var id: String = UUID.v4()
var cell: CellData
var abilities: Array[AbstractAbility]
var health: Health = Health.new()
var body: Node3D

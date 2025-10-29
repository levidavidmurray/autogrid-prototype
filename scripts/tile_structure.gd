class_name TileStructure
extends TileOccupant

enum EType { OBSTACLE, BUILDING }

var type: EType
var structure: Node3D

func _init(_type: EType, _structure: Node3D) -> void:
    self.type = _type
    self.structure = _structure
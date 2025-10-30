class_name TileUnit
extends TileOccupant

enum EType { PLAYER, ENEMY, NPC }

var type: EType
var unit: GridRunner


func _init(_type: EType, _unit: GridRunner) -> void:
    self.type = _type
    self.unit = _unit


func is_player() -> bool:
    return type == EType.PLAYER


func is_enemy() -> bool:
    return type == EType.ENEMY


func is_npc() -> bool:
    return type == EType.NPC


func _to_string() -> String:
    return "TileUnit(%s, %s)" % [EType.keys()[type], cell.coord]

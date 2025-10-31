class_name TileUnit
extends TileOccupant

enum EType { PLAYER, ENEMY, NPC }

var type: EType
var can_move: bool


func _init(_type: EType, _body: Node3D) -> void:
	self.type = _type
	self.body = _body


func is_player() -> bool:
	return type == EType.PLAYER


func is_enemy() -> bool:
	return type == EType.ENEMY


func is_npc() -> bool:
	return type == EType.NPC


func _to_string() -> String:
	var coord = Vector2i(-1, -1) if cell == null else cell.coord
	return "TileUnit(%s, %s)" % [EType.keys()[type], coord]

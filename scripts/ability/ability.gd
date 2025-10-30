class_name Ability
extends RefCounted

enum EAttribute {
	DAMAGE,
	MOVE_TARGET,
	MOVE_OWNER,
}

enum ECastType { ADJACENT, DIRECTED, JUMP, SELF }

var name: String
var description: String
var cast_type: ECastType
var attribute_map: Dictionary[EAttribute, Variant]
var effects_scene: PackedScene


func _init(data: Dictionary) -> void:
	self.name = data["name"]
	self.description = data["description"]
	self.cast_type = data["cast_type"]
	self.effects_scene = data["effects_scene"]

	var attributes_data = data["attributes"]
	for attribute in attributes_data:
		attribute_map[attribute] = attributes_data[attribute]


func execute(owner: TileOccupant, target: CellData) -> void:
	print("%s executes %s on %s" % [owner, self, target])
	var label = FloatingLabel.new(name)
	target.grid_square.add_child(label)
	label.top_level = true
	label.global_position.y += 0.25


func _to_string() -> String:
	return "Ability(%s)" % name

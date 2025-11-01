@abstract
class_name AbstractAbility
extends RefCounted

enum ECastType { ADJACENT, DIRECTED, JUMP, SELF }

var name: String = "Ability"
var cast_type: ECastType = ECastType.ADJACENT

func execute(owner: TileUnit, target_cell: CellData):
	var label_pos = target_cell.position
	label_pos.y += 0.75
	G.floating_label(name, label_pos)
	pass


func get_description() -> String:
	Log.warn("get_description for Ability(%s) is not implemented")
	return "Ability Description"

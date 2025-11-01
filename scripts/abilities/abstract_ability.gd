@abstract
class_name AbstractAbility
extends RefCounted

static var sfx_resource_map: Dictionary[String, AudioStream] = {}

enum ECastType { ADJACENT, DIRECTED, JUMP, SELF }

var name: String = "Ability"
var cast_type: ECastType = ECastType.ADJACENT


func execute(owner: TileUnit, target_cell: CellData):
	var label_pos = target_cell.position
	label_pos.y += 0.75
	G.floating_label(name, label_pos)


func play_sfx(volume_db: float = 0.0) -> void:
	AudioManager.play_stream(get_sfx(), volume_db)


func get_sfx() -> AudioStream:
	var resource_path = "res://assets/sfx/SFX_Ability_%s.wav" % (name.replace(" ", ""))
	if not sfx_resource_map.has(name):
		if not ResourceLoader.exists(resource_path):
			Log.warn("No SFX for Ability(%s) found: %s" % [name, resource_path])
			return null
		sfx_resource_map[name] = ResourceLoader.load(resource_path)

	return sfx_resource_map[name]


func get_description() -> String:
	Log.warn("get_description for Ability(%s) is not implemented")
	return "Ability Description"


func _to_string() -> String:
	return "Ability(%s)" % name
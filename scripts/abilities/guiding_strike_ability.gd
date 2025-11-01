class_name GuidingStrikeAbility
extends AbstractAbility


var damage: int = 1

func _init() -> void:
	self.name = "Guiding Strike"
	self.cast_type = ECastType.DIRECTED


func execute(owner: TileUnit, target_cell: CellData):
	super(owner, target_cell)

	var raw_dir = Grid.instance.get_direction_to_cell(owner.cell, target_cell)
	var stop_cell_dir = -(raw_dir.clampi(-1, 1))
	var stop_cell: CellData = Grid.instance.get_relative_cell(target_cell, stop_cell_dir)

	# await MoveAction.create(owner, raw_dir + stop_cell_dir)
	await SprintBounceAction.create(owner, target_cell)

	if target_cell.occupant:
		await DamageAction.create(target_cell.occupant, damage)

		var target_body = target_cell.occupant.body
		var scale_tween = target_body.create_tween()
		scale_tween.tween_property(target_body, "scale:y", 0.9, 0.05)
		scale_tween.tween_property(target_body, "scale:y", 1.0, 0.1)
		await PushAction.create(owner.cell, target_cell.occupant)


func play_sfx(volume_db: float = -10.0) -> void:
	super(volume_db)


func get_description() -> String:
	return "Deal %s damage" % damage

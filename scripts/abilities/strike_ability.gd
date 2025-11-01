class_name StrikeAbility
extends AbstractAbility

var damage: int = 2

func _init() -> void:
	self.name = "Strike"
	self.cast_type = ECastType.ADJACENT


func execute(owner: TileUnit, target_cell: CellData):
	super(owner, target_cell)

	play_sfx()
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

class_name StrikeAbility
extends AbstractAbility

var damage: int = 2

func _init() -> void:
	self.name = "Strike"
	self.cast_type = ECastType.ADJACENT


func get_description() -> String:
	return "Deal %s damage" % damage


func execute(owner: TileUnit, target_cell: CellData):
	super(owner, target_cell)

	if target_cell.occupant:
		await DamageAction.create(target_cell.occupant, damage)
		await PushAction.create(owner.cell, target_cell.occupant)

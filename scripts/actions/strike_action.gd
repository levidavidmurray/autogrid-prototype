# TODO: Refactor to Ability once I figure out the differentiation
class_name StrikeAction
extends AbstractAction

static var damage: int = 2

static func create(owner: TileUnit, target_cell: CellData):
	if target_cell.occupant:
		await DamageAction.create(target_cell.occupant, damage)
		await PushAction.create(owner.cell, target_cell.occupant)
	
	var label_pos = target_cell.position
	label_pos.y += 0.25
	G.floating_label("StrikeAction", label_pos)

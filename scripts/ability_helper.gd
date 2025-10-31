class_name AbilityHelper

static func get_possible_target_cells(ability: AbstractAbility, owner_cell: CellData) -> Array[CellData]:
	var targets: Array[CellData] = []

	if ability.cast_type == AbstractAbility.ECastType.ADJACENT:
		targets = owner_cell.get_neighbor_cells()

	return targets


static func can_target_cell(ability: AbstractAbility, owner_cell: CellData, target_cell: CellData) -> bool:
	var possible_cells = get_possible_target_cells(ability, owner_cell)
	return target_cell in possible_cells

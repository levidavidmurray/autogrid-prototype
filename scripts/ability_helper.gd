class_name AbilityHelper

static func get_possible_target_cells(ability: AbstractAbility, owner_cell: CellData) -> Array[CellData]:
	match ability.cast_type:
		AbstractAbility.ECastType.ADJACENT:
			return _get_adjacent_target_cells(owner_cell)
		AbstractAbility.ECastType.DIRECTED:
			return _get_directed_target_cells(owner_cell)

	return []


static func can_target_cell(ability: AbstractAbility, owner_cell: CellData, target_cell: CellData) -> bool:
	var possible_cells = get_possible_target_cells(ability, owner_cell)
	return target_cell in possible_cells


static func get_target_cell_for_ability(ability: AbstractAbility, owner_cell: CellData, target_cell: CellData) -> CellData:
	# TODO: This function should be generic enough for all ability cast types
	var target_dir = Grid.instance.get_direction_to_cell(owner_cell, target_cell)
	var target_cardinal_dir = GridUtils.vec2i_to_cardinal(target_dir)

	var final_cell: CellData = target_cell
	var final_cell_dist = target_dir.length()

	for cell in get_possible_target_cells(ability, owner_cell):
		var cell_dir = Grid.instance.get_direction_to_cell(owner_cell, cell)
		var cardinal_dir = GridUtils.vec2i_to_cardinal(cell_dir)
		var dist = cell_dir.length()
		if cardinal_dir == target_cardinal_dir and dist > final_cell_dist:
			final_cell = cell
			final_cell_dist = dist
	
	return final_cell


static func _get_adjacent_target_cells(cell: CellData) -> Array[CellData]:
	return cell.get_neighbor_cells()


static func _get_directed_target_cells(cell: CellData) -> Array[CellData]:
	var neighbors = cell.get_neighbor_cells()
	var cells: Array[CellData] = neighbors.duplicate()

	var cur_cell: CellData
	for neighbor in neighbors:
		cur_cell = neighbor
		var dir = Grid.instance.get_direction_to_cell(cell, neighbor)
		if cur_cell.occupant:
			continue
		while Grid.instance.is_valid_coord(cur_cell.coord + dir):
			cur_cell = Grid.instance.grid_to_cell(cur_cell.coord + dir)
			cells.append(cur_cell)
			if cur_cell.occupant:
				break

	return cells

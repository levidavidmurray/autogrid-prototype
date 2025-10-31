class_name NavigatePathAction
extends AbstractAction

static func create(unit: TileUnit, path: Array[CellData]):
	var cell_path = path.duplicate()
	var i = 0
	unit.can_move = false
	while i < cell_path.size():
		var cell: CellData = cell_path[i]
		i += 1
		if cell == unit.cell:
			continue
		await HopAction.create(unit.body, cell.position)
		await MoveAction.create(unit, Grid.instance.get_direction_to_cell(unit.cell, cell))
	unit.can_move = true

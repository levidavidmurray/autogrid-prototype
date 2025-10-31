class_name MoveAction
extends AbstractAction

static func create(target: TileOccupant, direction: Vector2i):
    var new_cell: CellData = Grid.instance.get_relative_cell(target.cell, direction)
    if new_cell.occupant == null:
        Grid.instance.set_cell_occupant(new_cell, target)

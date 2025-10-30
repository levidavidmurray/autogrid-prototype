class_name AbilityHelper
extends RefCounted

var grid: Grid

func _init(_grid: Grid) -> void:
    self.grid = _grid


func get_possible_target_cells(ability: Ability, owner_cell: CellData) -> Array[CellData]:
    var targets: Array[CellData] = []

    if ability.cast_type == Ability.ECastType.ADJACENT:
        targets = owner_cell.get_neighbor_cells()

    return targets


func can_target_cell(ability: Ability, owner_cell: CellData, target_cell: CellData) -> bool:
    var possible_cells = get_possible_target_cells(ability, owner_cell)
    return target_cell in possible_cells

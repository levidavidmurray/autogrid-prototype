class_name TileOccupant
extends RefCounted

signal cell_changed(prev: CellData, new: CellData)

var id: String = UUID.v4()

var cell: CellData:
    set(value):
        var prev = cell
        cell = value
        if emit_cell_change:
            cell_changed.emit(prev, cell)

var abilities: Array[AbstractAbility]
var health: Health = Health.new()
var body: Node3D

var emit_cell_change: bool = true

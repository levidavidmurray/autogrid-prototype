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


func execute(ability: Ability, owner: TileOccupant, target_cell: CellData) -> void:
	_create_execute_label(ability, owner, target_cell)
	Log.debug("%s executes %s on %s" % [owner, ability, target_cell])
	for attribute in ability.attribute_map:
		_apply_attribute(attribute, ability, owner, target_cell)


func _apply_attribute(attrib: Ability.EAttribute, ability: Ability, owner: TileOccupant, target_cell: CellData) -> void:
	assert(ability.attribute_map.has(attrib), "The given attribute (%s) is not present in %s" % [ Ability.EAttribute.keys()[attrib], ability])
	var occupant: TileOccupant = target_cell.occupant
	var attrib_value: Variant = ability.attribute_map[attrib]
	match attrib:
		Ability.EAttribute.DAMAGE:
			if occupant == null:
				return
			occupant.health.remove_health(attrib_value as int)
		_:
			_log_attribute_implementation_warning(attrib)


func _create_execute_label(ability: Ability, owner: TileOccupant, target: CellData) -> void:
	var label_pos = target.grid_square.global_position
	label_pos.y += 0.25
	G.floating_label(ability.name, label_pos)


func _log_attribute_implementation_warning(attribute: Ability.EAttribute) -> void:
	Log.warn("Attribute not implemented: %s" % Ability.EAttribute.keys()[attribute])

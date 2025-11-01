class_name AbilityIntent
extends RefCounted

var target_direction: Vector2i
var ability: AbstractAbility

func _init(_ability: AbstractAbility, _target_direction: Vector2i) -> void:
    self.target_direction = _target_direction
    self.ability = _ability

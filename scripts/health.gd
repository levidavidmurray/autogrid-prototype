class_name Health
extends RefCounted

signal died
signal max_health_changed(new_max_health: int)
signal current_health_changed(prev_health: int, new_health: int)

var max_health: int:
	set(value):
		max_health = value
		if current_health > max_health:
			current_health = max_health
		max_health_changed.emit(max_health)

var current_health: int:
	set(value):
		var prev_health = current_health
		current_health = clampi(value, 0, max_health)
		current_health_changed.emit(prev_health, current_health)


func _init(_max_health: int = 5) -> void:
	self.max_health = _max_health
	current_health = max_health


func add_health(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)


func remove_health(amount: int) -> void:
	current_health = clampi(current_health - amount, 0, max_health)
	if current_health <= 0:
		died.emit()


func get_health_string() -> String:
	return "%s/%s" % [current_health, max_health]

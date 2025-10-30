@tool
class_name Shape
extends Node3D

@export var mesh_instance: MeshInstance3D

@export var mesh_scale: Vector3 = Vector3.ONE:
	set(value):
		mesh_scale = value
		_update_shape_data()

@export var albedo_color: Color = Color.WHITE:
	set(value):
		albedo_color = value
		_update_shape_data()

@export var outline_color: Color = Color.WHITE:
	set(value):
		outline_color = value
		_update_shape_data()

var material: StandardMaterial3D
var outline_material: ShaderMaterial

func _ready() -> void:
	material = mesh_instance.get_surface_override_material(0)
	outline_material = material.next_pass
	_update_shape_data()

func _update_shape_data() -> void:
	if mesh_instance == null or material == null:
		return
	material.albedo_color = albedo_color
	mesh_instance.scale = mesh_scale
	mesh_instance.position.y = 0.0
	outline_material.set_shader_parameter("outline_color", outline_color)

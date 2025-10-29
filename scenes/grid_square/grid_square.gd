@tool
class_name GridSquare
extends Node3D

@export var cell_size: float = 1.0:
    set(value):
        cell_size = value
        if mesh:
            mesh.size = Vector2.ONE * (cell_size + line_width)

@export_category("Shader Parameters")

@export var base_color: Color = Color("18243d"):
    set(value):
        base_color = value
        if material:
            material.set_shader_parameter("base_color", base_color)

@export var line_color: Color = Color.WHITE:
    set(value):
        line_color = value
        if material:
            material.set_shader_parameter("line_color", line_color)

@export var line_width: float = 0.02:
    set(value):
        line_width = value
        if mesh:
            mesh.size = Vector2.ONE * (cell_size + line_width)
        if material:
            material.set_shader_parameter("line_width", line_width)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var mesh: QuadMesh
var material: ShaderMaterial

func _ready() -> void:
    mesh = mesh_instance.mesh as QuadMesh
    material = mesh_instance.get_surface_override_material(0)
    force_update_square()


func force_update_square() -> void:
    if mesh == null or material == null:
        return
    mesh.size = Vector2.ONE * (cell_size + line_width)
    material.set_shader_parameter("base_color", base_color)
    material.set_shader_parameter("line_color", line_color)
    material.set_shader_parameter("line_width", line_width)

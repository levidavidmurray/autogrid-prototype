@tool
class_name GridSquare
extends Node3D

@export var cell_size: float = 1.0:
	set(value):
		cell_size = value
		if mesh:
			mesh.size = Vector2.ONE * (cell_size + line_width)

@export_category("Shader Parameters")

@export var line_width: float = 0.02:
	set(value):
		line_width = value
		if mesh:
			mesh.size = Vector2.ONE * (cell_size + line_width)
		if material:
			material.set_shader_parameter("line_width", line_width)

@export_category("Colors")
@export var debug_label_color: Color = Color("#364f79")
@export var base_color: Color = Color("#18243d")
@export var line_color: Color
@export var hover_base_color: Color
@export var hover_outline_color: Color
@export var selected_base_color: Color
@export var selected_outline_color: Color
@export var moveable_base_color: Color
@export var moveable_outline_color: Color
@export var targeted_base_color: Color
@export var targeted_outline_color: Color

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var debug_label: Label3D = $DebugLabel

var mesh: QuadMesh
var material: ShaderMaterial

var target_base_color: Color
var target_outline_color: Color

var is_dirty: bool = true

var text_hsv_offset: Vector3
var hover_base_hsv_offset: Vector3
var hover_outline_hsv_offset: Vector3

var is_hovered: bool:
	set(value):
		if is_hovered == value:
			return
		is_hovered = value
		is_dirty = true

var is_selected: bool:
	set(value):
		if is_selected == value:
			return
		is_selected = value
		is_dirty = true

var is_moveable: bool:
	set(value):
		if is_moveable == value:
			return
		is_moveable = value
		is_dirty = true

var is_targeted: bool:
	set(value):
		if is_targeted == value:
			return
		is_targeted = value
		is_dirty = true


func _ready() -> void:
	mesh = mesh_instance.mesh as QuadMesh
	material = mesh_instance.get_surface_override_material(0)
	_set_hsv_offsets()
	force_update_square()


func _process(_delta: float) -> void:
	if is_dirty:
		_update_colors()
		is_dirty = false


func force_update_square() -> void:
	if mesh == null or material == null:
		return
	mesh.size = Vector2.ONE * (cell_size + line_width)
	_update_colors()
	material.set_shader_parameter("line_width", line_width)


func _update_colors() -> void:
	_calculate_target_colors()
	_set_colors()


func _set_colors() -> void:
	material.set_shader_parameter("base_color", target_base_color)
	material.set_shader_parameter("line_color", target_outline_color)
	debug_label.modulate = _get_offset_color(text_hsv_offset, target_base_color)


func _set_hsv_offsets() -> void:
	var base_hsv = G.color_to_hsv(base_color)
	var outline_hsv = G.color_to_hsv(line_color)
	var hover_base_hsv = G.color_to_hsv(hover_base_color)
	var hover_outline_hsv = G.color_to_hsv(hover_outline_color)
	var text_hsv = G.color_to_hsv(debug_label_color)

	hover_base_hsv_offset = hover_base_hsv - base_hsv
	hover_outline_hsv_offset = hover_outline_hsv - outline_hsv
	text_hsv_offset = text_hsv - base_hsv


func _calculate_target_colors() -> void:
	var new_base_color = base_color
	var new_outline_color = line_color

	if is_moveable:
		new_base_color = moveable_base_color
		new_outline_color = moveable_outline_color
		mesh_instance.position.y = 0.003
	elif is_targeted:
		new_base_color = targeted_base_color
		new_outline_color = targeted_outline_color
		mesh_instance.position.y = 0.003
	elif is_selected:
		new_base_color = selected_base_color
		new_outline_color = selected_outline_color
		mesh_instance.position.y = 0.001
	else:
		new_base_color = base_color
		new_outline_color = line_color
		mesh_instance.position.y = 0.0

	if is_hovered:
		new_base_color = _get_offset_color(hover_base_hsv_offset, new_base_color)
		new_base_color = _get_offset_color(hover_outline_hsv_offset, new_outline_color)
		mesh_instance.position.y = 0.002
	
	target_base_color = new_base_color
	target_outline_color = new_outline_color


func _get_offset_color(hsv_offset: Vector3, color: Color) -> Color:
	var color_hsv = G.color_to_hsv(color)
	var new_h = color_hsv.x + hsv_offset.x
	var new_s = clampf(color_hsv.y + hsv_offset.y, 0.0, 1.0)
	var new_v = clampf(color_hsv.z + hsv_offset.z, 0.0, 1.0)
	return Color.from_hsv(new_h, new_s, new_v)

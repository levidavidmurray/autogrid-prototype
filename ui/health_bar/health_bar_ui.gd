@tool
class_name HealthBarUI
extends Control

@export var pip_color: Color = Color.WHITE:
    set(value):
        pip_color = value
        _update_pips()

@export var max_health: int = 5:
    set(value):
        if value == max_health:
            return
        max_health = value
        if current_health > max_health:
            current_health = max_health
        size.x = _get_width_for_max_health()
        _constrain_to_size()
        _create_pips()
        if Engine.is_editor_hint():
            if current_health < max_health:
                current_health = max_health

@export var current_health: int = 5:
    set(value):
        if value == current_health:
            return
        current_health = value
        _update_pips()

@export var debug_delete_pips: bool:
    set(value):
        if pip_container:
            for child in pip_container.get_children():
                child.free()
            pass

@onready var pip_container: Control = %PipContainer
@onready var frame_top: ColorRect = %FrameTop
@onready var frame_bottom: ColorRect = %FrameBottom
@onready var frame_left: ColorRect = %FrameLeft
@onready var frame_right: ColorRect = %FrameRight

var max_health_size_map: Dictionary[int, float] = {
    1: 48,
    2: 48,
    3: 61,
    4: 64,
    5: 77,
    6: 77,
    8: 90,
    12: 100,
    24: 120,
    30: 140,
}

var max_health_separation_map: Dictionary[int, float] = {
    1: 2,
    19: 1,
}

var pips: Array[ColorRect]
var last_width: float
var pip_container_target_size: Vector2

func _ready() -> void:
    size.x = _get_width_for_max_health()
    _constrain_to_size()
    _create_pips()
    pip_container_target_size = pip_container.size


func _process(delta: float) -> void:
    if last_width != size.x:
        _constrain_to_size()
        _update_pips_width()

    last_width = size.x


func _constrain_to_size() -> void:
    if not is_inside_tree():
        return
    frame_top.size.x = size.x
    frame_bottom.size.x = size.x
    frame_right.position.x = size.x - 1
    frame_right.size.y = size.y
    frame_left.size.y = size.y
    frame_bottom.position.y = size.y - 1
    pip_container_target_size = size - Vector2(4, 4)
    pip_container.size = pip_container_target_size


func _get_width_for_max_health() -> float:
    var max_value: int = 1
    for health_count in max_health_size_map:
        if health_count > max_health:
            break
        max_value = health_count
    return max_health_size_map[max_value]


func _get_separation_for_max_health() -> float:
    var max_value: int = 1
    for health_count in max_health_separation_map:
        if health_count > max_health:
            break
        max_value = health_count
    return max_health_separation_map[max_value]


func _create_pips() -> void:
    if not is_inside_tree():
        return

    for child in pip_container.get_children():
        child.free()
    pips.clear()

    for i in range(max_health):
        var pip = ColorRect.new()
        # pip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        pip_container.add_child(pip)
        pips.append(pip)
        pip.owner = get_tree().edited_scene_root

    _update_pips_width()
    _update_pips()


func _update_pips_width() -> void:
    var container_width = pip_container_target_size.x
    var separation: float = _get_separation_for_max_health()
    var base_pip_width: float = (container_width - (separation * (max_health - 1))) / float(max_health)
    base_pip_width = floorf(base_pip_width)

    # Very dumb stuff just trying to make it work...
    size.x = ((base_pip_width * max_health) + (separation * (max_health - 1))) + 4.0
    _constrain_to_size()
    container_width = pip_container_target_size.x

    var width_total: float = 0.0

    for i in range(pips.size()):
        var pip = pips[i]
        var pip_width = base_pip_width
        if i == pips.size() - 1:
            if width_total + (base_pip_width) > container_width:
                pip_width = container_width - width_total
        var pos_x = i * (pip_width + separation)
        pip.custom_minimum_size = Vector2(pip_width, pip_container_target_size.y)
        pip.position.x = pos_x
        var added_width = pip_width
        if i != pips.size() - 1:
            added_width += separation
        width_total += added_width
    pip_container.size = pip_container_target_size
    last_width = size.x


func _update_pips() -> void:
    if not is_inside_tree():
        return
    var reversed_pips = pips.duplicate()
    if reversed_pips.size() < max_health:
        return
    for i in range(max_health):
        var pip = reversed_pips[i] as ColorRect
        pip.modulate = pip_color

        if i + 1 > current_health:
            pip.hide()
        else:
            pip.show()

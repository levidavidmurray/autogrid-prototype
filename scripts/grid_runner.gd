class_name GridRunner
extends Node3D

enum EState {
    IDLE,
    MOVING
}

var grid: Grid
var current_cell: Vector2i
var is_cell_dirty: bool = true
var debug_label: Label3D

var state: EState = EState.MOVING
var run_direction: Vector2i = Vector2i(1, 0)
var move_interval: float = 0.5
var jump_time: float = 0.35
var last_move_time: float
var jump_time_remaining: float
var scale_tween: Tween
var shape: Node3D

var is_moving: bool:
    get():
        return state == EState.MOVING


func _ready() -> void:
    last_move_time = G.get_time()
    jump_time_remaining = jump_time


func _process(delta: float) -> void:
    if not debug_label:
        _create_debug_label()

    # run_direction = Vector2i(-1, 0)
    # _handle_move()
    _calculate_jump(delta)


func _handle_move():
    var next_cell = _get_next_cell()
    if G.get_time() - last_move_time >= move_interval and is_moving:
        current_cell = next_cell
        last_move_time = G.get_time()


func _calculate_jump(delta: float):
    var config = DebugDraw3D.new_scoped_config()
    config.set_thickness(0.01)
    config.set_no_depth_test(true)

    var next_cell = _get_next_cell()
    debug_label.hide()
    var origin_pos = grid.grid_to_world(current_cell)
    var origin_control = origin_pos + Vector3(0.0, 1.0, 0.0)
    var target_pos = grid.grid_to_world(next_cell)
    var target_control = target_pos + Vector3(0.0, 1.0, 0.0)
    # DebugDraw3D.draw_sphere(origin_pos, 0.05, Color.ORANGE)
    # DebugDraw3D.draw_sphere(origin_control, 0.05, Color.YELLOW)
    # DebugDraw3D.draw_sphere(target_pos, 0.05, Color.RED)
    # DebugDraw3D.draw_sphere(target_control, 0.05, Color.YELLOW)

    jump_time = 0.35
    var land_delay_time = 0.5
    if G.get_time() - last_move_time < land_delay_time:
        return

    # var t = clampf(1.0 - (jump_time_remaining / jump_time), 0.0, 1.0)
    var elapsed_time = clampf(jump_time - jump_time_remaining, 0.0, jump_time)
    var t = Tween.interpolate_value(0.0, 1.0, elapsed_time, jump_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    var jump_pos = G.get_bezier_position(origin_pos, origin_control, target_pos, target_control, t)
    global_position = jump_pos
    jump_time_remaining -= delta

    if t >= 0.5 and (not scale_tween or not scale_tween.is_running()):
        scale_tween = create_tween()
        scale_tween.tween_property(shape, "scale", Vector3(1.2, 0.8, 1.2), 0.2)
        scale_tween.tween_property(shape, "scale", Vector3.ONE, 0.2)

    if t >= 1.0:
        # Single frame land
        current_cell = next_cell
        last_move_time = G.get_time()
        jump_time_remaining = jump_time

    # var bake_size = 50
    # for i in range(bake_size):
    #     var t = i/float(bake_size)
    #     var pos = G.get_bezier_position(origin_pos, origin_control, target_pos, target_control, t)
    #     DebugDraw3D.draw_sphere(pos, 0.02, Color.GREEN)

    # DebugDraw3D.draw_sphere(grid.grid_to_world(next_cell), 0.05, Color.RED)



func _create_debug_label() -> void:
    debug_label = Label3D.new()
    debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    debug_label.position.y = 1.0
    add_child(debug_label)


func _get_next_cell() -> Vector2i:
    if run_direction.x == 1 and current_cell.x == grid.grid_size.x - 1:
        run_direction.x = -1
    elif run_direction.x == -1 and current_cell.x == 0:
        run_direction.x = 1

    if run_direction.y == 1 and current_cell.y == grid.grid_size.y - 1:
        run_direction.y = -1
    elif run_direction.y == -1 and current_cell.y == 0:
        run_direction.y = 1

    return current_cell + run_direction

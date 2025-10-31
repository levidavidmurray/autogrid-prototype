class_name HopAction
extends AbstractAction

static func create(node: Node3D, target_position: Vector3):
    var jump_time: float = 0.25
    var start_time: float = G.get_time()
    var elapsed_time: float = 0.0

    var start_pos = node.global_position
    var start_control = start_pos + Vector3(0.0, 0.5, 0.0)
    var end_pos = target_position
    var end_control = end_pos + Vector3(0.0, 0.5, 0.0)
    var tween: Tween = null

    while elapsed_time < jump_time:
        var t = Tween.interpolate_value(0.0, 1.0, elapsed_time, jump_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
        var cur_pos = G.get_bezier_position(start_pos, start_control, end_pos, end_control, t)
        node.global_position = cur_pos

        if t >= 0.5 and (tween == null or not tween.is_running()):
            tween = node.create_tween()
            var tween_time = jump_time / 2.0
            tween.tween_property(node, "scale", Vector3(1.2, 0.8, 1.2), tween_time)
            tween.tween_property(node, "scale", Vector3.ONE, tween_time)

        elapsed_time = G.get_time() - start_time
        await node.get_tree().process_frame

    # finished once here

class_name PushAction
extends AbstractAction

static func create(source: CellData, target: TileOccupant):
    var push_dir = Grid.instance.get_direction_to_cell(source, target.cell).clampi(-1, 1)
    var new_cell = Grid.instance.get_relative_cell(target.cell, push_dir)

    if new_cell and new_cell.occupant != null:
        # TODO: Handle knock impact
        return

    var push_time = 0.15
    var target_pos: Vector3
    if new_cell != null:
        target_pos = new_cell.position
    else:
        var cur_pos = target.cell.position
        var grid_square = target.cell.grid_square
        target_pos = cur_pos + (Vector3(push_dir.x, 0.0, push_dir.y) * grid_square.cell_size)

    var tween = target.body.create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(target.body, "global_position", target_pos, push_time)

    if new_cell == null:
        # Pushing off grid. Tween back to current cell
        tween.tween_property(target.body, "global_position", target.cell.position, push_time)

    await tween.finished
    await MoveAction.create(target, push_dir)

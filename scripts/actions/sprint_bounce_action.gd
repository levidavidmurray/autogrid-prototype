class_name SprintBounceAction
extends AbstractAction

static func create(target: TileOccupant, target_cell: CellData):
    var move_dir = Grid.instance.get_direction_to_cell(target.cell, target_cell)
    var clamped_dir = -move_dir.clampi(-1, 1)
    var final_cell = Grid.instance.get_relative_cell(target_cell, clamped_dir)

    var bounce_dir = target_cell.position.direction_to(final_cell.position)
    var undershoot = bounce_dir * (Grid.instance.cell_size / 2.0)

    var move_time = min(move_dir.length(), 2) * 0.1
    var tween = target.body.create_tween()
    tween.set_trans(Tween.TRANS_EXPO)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(target.body, "global_position", target_cell.position + undershoot, move_time)
    tween.tween_property(target.body, "global_position", final_cell.position, 0.1)
    await G.wait(move_time * 0.75)
    MoveAction.create(target, move_dir + clamped_dir)

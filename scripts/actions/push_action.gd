class_name PushAction
extends AbstractAction

static func create(source: CellData, target: TileOccupant):
    var push_dir = Grid.instance.get_direction_to_cell(source, target.cell)
    var new_cell = Grid.instance.get_relative_cell(target.cell, push_dir)
    if new_cell == null:
        return

    if new_cell.occupant != null:
        # TODO: Handle knock impact
        return

    var push_time = 0.15
    var target_pos = new_cell.position

    var tween = target.body.create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(target.body, "global_position", target_pos, push_time)

    await tween.finished
    await MoveAction.create(target, push_dir)

class_name DamageAction
extends AbstractAction

static func create(target: TileOccupant, damage: int):
    target.health.remove_health(damage)

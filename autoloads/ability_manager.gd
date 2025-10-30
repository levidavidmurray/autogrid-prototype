extends Node

const abilities_data: Array[Dictionary] = [
    {
        "name": "Strike",
        "description": "Deal 2 damage",
        "cast_type": Ability.ECastType.ADJACENT,
        "attributes": {
            Ability.EAttribute.DAMAGE: 2,
        },
        "effects_scene": null,
    }
]

var abilities: Array[Ability]
var grid: Grid


func _ready() -> void:
    _populate_abilities()


func get_ability_by_name(ability_name: String) -> Ability:
    var index = abilities.find_custom(func(a: Ability): return a.name == ability_name)
    if index == -1:
        return null
    return abilities[index]


func _populate_abilities() -> void:
    for data in abilities_data:
        var ability = Ability.new(data)
        abilities.append(ability)

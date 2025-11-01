class_name GuidingStrikeAbility
extends AbstractAbility

static var sfx_dash_stream: AudioStream = load("res://assets/sfx/SFX_Ability_GuidingStrike_Dash.wav")

var damage: int = 1

func _init() -> void:
	self.name = "Guiding Strike"
	self.cast_type = ECastType.DIRECTED


func execute(owner: TileUnit, target_cell: CellData):
	super(owner, target_cell)

	var raw_dir = Grid.instance.get_direction_to_cell(owner.cell, target_cell)

	var dash_pitch = remap(raw_dir.length(), 1, 8, 1.1, 0.8)
	var dash_sound = SoundData.new(sfx_dash_stream, 0.0, dash_pitch)
	AudioManager.play_sound(dash_sound)

	if target_cell.occupant:
		AudioManager.play_sound(SoundData.new(get_sfx(), -10.0, 1.0, 0.1))

	await SprintBounceAction.create(owner, target_cell)

	if target_cell.occupant:
		await DamageAction.create(target_cell.occupant, damage)

		var target_body = target_cell.occupant.body
		var scale_tween = target_body.create_tween()
		scale_tween.tween_property(target_body, "scale:y", 0.9, 0.05)
		scale_tween.tween_property(target_body, "scale:y", 1.0, 0.1)
		await PushAction.create(owner.cell, target_cell.occupant)


func play_sfx(volume_db: float = -10.0) -> void:
	super(volume_db)


func get_description() -> String:
	return "Deal %s damage" % damage

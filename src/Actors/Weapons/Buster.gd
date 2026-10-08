extends Weapon
class_name Buster

var laser_active := false
var laser_shot : Node = null
var laser_duration := 2.5
var removed_stasis_conflict := false

func _ready() -> void :
	._ready()
	Event.listen("shot_lemon", self, "on_lemon_shot_created")

func on_lemon_shot_created(emitter, shot: KinematicBody2D) -> void :
	if emitter != self:
		connect_shot_event(shot)

func add_projectile_to_scene(charge_level: int):
	var shot: KinematicBody2D = .add_projectile_to_scene(charge_level)
	if charge_level < 1:
		Event.emit_signal("shot_lemon", self, shot)
	if charge_level >= 3 and is_instance_valid(shot) and ("Laser" in shot.name):
		start_laser_lock(shot)

func has_ammo() -> bool:
	_validate_laser()
	return shots_currently_alive < max_shots_alive and not laser_active

func is_cooling_down() -> bool:
	_validate_laser()
	return laser_active

func connect_charged_shot_event(_shot: KinematicBody2D) -> void :
	_shot.connect("projectile_started", self, "on_charged_shot_created")
	_shot.connect("projectile_end", self, "on_charged_shot_end")
	if _shot.has_method("set_creator"):
		_shot.set_creator(arm_cannon.character)
	if _shot.has_method("initialize"):
		_shot.call_deferred("initialize", arm_cannon.character.get_facing_direction())

func on_charged_shot_end(_shot: KinematicBody2D) -> void :
	charged_shots_currently_alive -= 1
	if _shot == laser_shot or (is_instance_valid(_shot) and ("Laser" in _shot.name)):
		end_laser_lock()

func _physics_process(_delta: float) -> void :
	if not laser_active:
		return
	if not is_instance_valid(laser_shot) or not is_instance_valid(character):
		end_laser_lock()
		return
	# Beam visual ends when the projectile leaves attack_stage 0 (SqueezeBomb
	# plays its "end" fade, then idles ~1s invisible before destroy). Unlock
	# with the beam, not with destroy.
	var stage = laser_shot.get("attack_stage")
	if stage != null and int(stage) >= 1:
		end_laser_lock()
		return
	if character.is_executing("Damage") or character.is_executing("Death") or character.is_executing("Ride") or character.is_executing("Forced"):
		return
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	if character.has_method("set_bonus_horizontal_speed"):
		character.set_bonus_horizontal_speed(0)

func start_laser_lock(shot: Node) -> void :
	if laser_active:
		return
	laser_active = true
	laser_shot = shot
	laser_duration = 2.5
	var d = shot.get("duration")
	if d != null:
		laser_duration = float(d) + 0.3
	if is_instance_valid(arm_cannon):
		arm_cannon.arm_point_dur = laser_duration + 0.3
		if "WeaponStasis" in arm_cannon.conflicting_moves:
			arm_cannon.conflicting_moves.erase("WeaponStasis")
			removed_stasis_conflict = true
	if is_instance_valid(character):
		character.set_meta("laser_lock", true)
		var sp = character.get_node_or_null("Shot Position")
		if sp != null and is_instance_valid(shot):
			var y_off := -1.0
			if not character.is_on_floor() and character.get_vertical_speed() < 0.0:
				y_off = -3.0
			shot.global_position.y = sp.global_position.y + y_off
		var stasis = character.get_node_or_null("WeaponStasis")
		if stasis and not stasis.executing:
			stasis.ExecuteOnce()
		character.set_horizontal_speed(0)
		character.set_vertical_speed(0)
		if character.has_method("set_bonus_horizontal_speed"):
			character.set_bonus_horizontal_speed(0)

func end_laser_lock() -> void :
	if is_instance_valid(character) and character.has_meta("laser_lock"):
		character.remove_meta("laser_lock")
	if is_instance_valid(arm_cannon) and removed_stasis_conflict:
		if not ("WeaponStasis" in arm_cannon.conflicting_moves):
			arm_cannon.conflicting_moves.append("WeaponStasis")
		removed_stasis_conflict = false
	if not laser_active:
		return
	laser_active = false
	laser_shot = null
	if is_instance_valid(arm_cannon):
		arm_cannon.arm_point_dur = 0.0
		if arm_cannon.get("executing") != null and arm_cannon.executing:
			arm_cannon.EndAbility()
	if is_instance_valid(character):
		var stasis = character.get_node_or_null("WeaponStasis")
		if stasis and stasis.executing:
			stasis.EndAbility()
		character.set_horizontal_speed(0)
		character.set_vertical_speed(0)

func _validate_laser() -> void :
	if laser_active and not is_instance_valid(laser_shot):
		end_laser_lock()

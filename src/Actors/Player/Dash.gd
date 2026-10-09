extends Movement
class_name Dash

export  var dash_duration: = 0.55
export  var leeway: = 0.1
export  var shot_pos_adjust: = Vector2(18, 4)

onready var particles = character.get_node("animatedSprite").get_node("Dash Smoke Particles")
onready var dash_particle = get_node("dash_particle")

var ghost_particle
var _dash
var ghost_dash: bool = false
var saved_damage_threshold: float = 0.0
var ghost_threshold_applied: bool = false
var emitted_dash: = false
var left_ground_timer: = 0.0
var can_dash: = true


func get_shot_adust_position() -> Vector2:
	return shot_pos_adjust

func _ready() -> void :
	ghost_particle = get_node("particles2D")
	
func get_activation_leeway_time() -> float:
	return leeway

func _Setup() -> void :
	Event.emit_signal("dash")
	set_direction(get_pressed_direction())
	update_bonus_horizontal_only_conveyor()
	emit_particles(particles, true)
	character.reduce_hitbox()
	apply_ghost_threshold()
	emitted_dash = false
	changed_animation = false
	left_ground_timer = 0
	can_dash = true
	deactivate_low_jumpcasts()
	jumpcast_timer = 0

func emit_dash_particle():
	if not emitted_dash:
		if get_pressed_direction() != 0:
			_dash = dash_particle.emit(get_pressed_direction())
		else:
			_dash = dash_particle.emit(character.get_facing_direction())
		emitted_dash = true

func _Update(_delta: float) -> void :
	increase_left_ground_timer(_delta)
	if can_dash and should_dash():
		on_dash()
		force_movement(horizontal_velocity)
		emit_dash_particle()
		if not character.is_on_floor():
			character.set_vertical_speed(0)
	else:
		can_dash = false
		if left_ground_timer == 0.0:
			left_ground_timer = 0.01
			character.set_vertical_speed(0)
			remove_ghost_threshold()
		change_animation_if_falling("fall")
		set_movement_and_direction(horizontal_velocity)
		process_gravity(_delta)

func increase_left_ground_timer(_delta: float) -> void :
	if left_ground_timer > 0.0:
		left_ground_timer += _delta

func process_gravity(delta: float, gravity: float = default_gravity, _s = "null") -> void :
	.process_gravity(delta, gravity)
	activate_low_jumpcasts_after_delay(delta)

func on_dash() -> void :
	pass

func change_animation_if_falling(_s) -> void :
	EndAbility()
	character.start_dashfall()

func _Interrupt() -> void :
	if not changed_animation:
		character.call_deferred("increase_hitbox")
	emit_particles(particles, false)
	remove_ghost_threshold()
	._Interrupt()

func has_ghost_legs() -> bool:
	return ghost_dash == true

func apply_ghost_threshold() -> void :
	if ghost_threshold_applied or not has_ghost_legs():
		return
	var dmg = character.get_node_or_null("Damage")
	if dmg == null:
		return
	var base_t: float = 0.0
	if is_instance_valid(character) and character.get("base_damage_threshold") != null:
		base_t = character.get("base_damage_threshold")
	saved_damage_threshold = dmg.damage_threshold
	dmg.damage_threshold = max(saved_damage_threshold, base_t + 3.0)
	ghost_threshold_applied = true
	set_ghost_fade(true)
	if is_instance_valid(ghost_particle):
		ghost_particle.emitting = true

func remove_ghost_threshold() -> void :
	if not ghost_threshold_applied:
		return
	ghost_threshold_applied = false
	var dmg = character.get_node_or_null("Damage")
	if dmg != null:
		dmg.damage_threshold = saved_damage_threshold
	set_ghost_fade(false)
	if is_instance_valid(ghost_particle):
		ghost_particle.emitting = false

func set_ghost_fade(enabled: bool) -> void :
	if not is_instance_valid(character) or character.animatedSprite == null:
		return
	if enabled:
		var c = character.animatedSprite.modulate
		c.a = 0.2
		character.animatedSprite.modulate = c
	else:
		var c2 = character.animatedSprite.modulate
		c2.a = 1.0
		character.animatedSprite.modulate = c2

func should_dash() -> bool:
	return character.is_on_floor()

func _StartCondition() -> bool:
	if facing_a_wall():
		return false
	if should_dash():
		return true
	return false

func _EndCondition() -> bool:
	if facing_a_wall():
		return true
	if character.is_on_floor():
		if left_ground_timer > 0.1:
			on_touch_floor()
			return true
		if not Is_Input_Happening():
			return true
		elif Has_time_ran_out():
			return true
		elif character.facing_right and character.has_just_pressed_left():
			last_time_pressed = 0.0
			return true
		elif not character.facing_right and character.has_just_pressed_right():
			last_time_pressed = 0.0
			return true
	return false

func Has_time_ran_out() -> bool:
	return dash_duration < timer

func stop_particles() -> void :
	particles.visible = false

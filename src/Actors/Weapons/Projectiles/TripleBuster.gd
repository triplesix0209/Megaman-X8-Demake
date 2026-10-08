extends ChargedBuster

func projectile_setup(dir : int, position : Vector2, _launcher_velocity := 0.0):
	.projectile_setup(dir, position)
	call_deferred("create_auxiliary_shots",dir)

func spawn_triad_copy(dir: int, h_speed: float, v_speed: float):
	var triad_scene = load("res://src/Actors/Weapons/Projectiles/Triad Charged Buster.tscn")
	var s = triad_scene.instance()
	get_tree().root.add_child(s, true)
	s.global_position = global_position
	s.set_direction(dir)
	s.set_horizontal_speed(h_speed)
	s.set_vertical_speed(v_speed, false)
	s.update_facing_direction()
	orient_diagonal_visual(s)
	return s

func orient_diagonal_visual(s) -> void:
	var hs = s.get_horizontal_speed()
	var vs = s.get_vertical_speed()
	if vs < 0 and hs > 0:
		s.rotation_degrees = -45.0
	elif vs < 0 and hs < 0:
		s.rotation_degrees = -135.0
	elif vs > 0 and hs > 0:
		s.rotation_degrees = 45.0
	elif vs > 0 and hs < 0:
		s.rotation_degrees = 135.0

func create_auxiliary_shots(dir) -> void:
	if is_xdrive_active():
		create_five_way_shots(dir)
		return
	var aux_velocity = horizontal_velocity
	var up_speed = aux_velocity * 0.7071
	var down_speed = aux_velocity * 0.7071
	var h = aux_velocity * 0.7071 * dir
	spawn_triad_copy(dir, h, -up_speed)
	spawn_triad_copy(dir, h, down_speed)

func is_xdrive_active() -> bool:
	var player = GameManager.player
	if player == null or not is_instance_valid(player):
		return false
	var xdrive = player.get_node_or_null("Shot/XDrive")
	if xdrive != null and xdrive.get("buffed") != null:
		return bool(xdrive.get("buffed"))
	if player.get("toggleable_invulnerabilities") != null:
		return "xdrive" in player.toggleable_invulnerabilities
	return false

func create_five_way_shots(dir) -> void:
	var aux_velocity = horizontal_velocity
	var h_diag = aux_velocity * 0.7071 * dir
	var v_diag = aux_velocity * 0.7071
	var h_shallow = aux_velocity * 0.9239 * dir
	var v_shallow = aux_velocity * 0.3827
	spawn_triad_copy(dir, h_diag, -v_diag)
	spawn_triad_copy(dir, h_diag, v_diag)
	spawn_triad_copy(dir, h_shallow, -v_shallow)
	spawn_triad_copy(dir, h_shallow, v_shallow)
	

extends ConfirmButton

export var post_confirm: String


func _ready() -> void :
	pass

func on_press() -> void :
	times_pressed += 1
	if times_pressed == 1:
		if not flashed:
			strong_flash()
			flashed = true
			menu.play_equip_sound()
		text.text = tr(confirmation)
	if times_pressed == 2:
		menu.play_cancel_sound()
		strong_flash()
		action()
		text.text = tr(post_confirm)

func action() -> void :
	var all_collectibles := [
		"finished_intro",
		"panda_weapon",
		"sunflower_weapon",
		"trilobyte_weapon",
		"manowar_weapon",
		"yeti_weapon",
		"rooster_weapon",
		"antonion_weapon",
		"mantis_weapon",
		"life_up_panda",
		"life_up_sunflower",
		"life_up_trilobyte",
		"life_up_manowar",
		"life_up_yeti",
		"life_up_rooster",
		"life_up_antonion",
		"life_up_mantis",
		"subtank_trilobyte",
		"subtank_sunflower",
		"subtank_yeti",
		"subtank_rooster",
		"hermes_head",
		"hermes_body",
		"hermes_arms",
		"hermes_legs",
		"icarus_head",
		"icarus_body",
		"icarus_arms",
		"icarus_legs",
		"ultima_head",
		"ultima_body",
		"ultima_arms",
		"ultima_legs",
		"black_zero_armor",
		"white_axl_armor",
		"zero_seen",
		"zero_defeated",
		"seen_zero",
		"z_saber_zero",
		"b_fan_zero",
		"d_glaive_zero",
		"k_knuckle_zero",
		"t_breaker_zero",
		"defeated_antonion_vile",
		"defeated_panda_vile",
		"vile3_defeated",
		"vile_palace_defeated",
		"copy_sigma_defeated",
		"seraph_lumine_defeated",
	]
	for collectible in all_collectibles:
		GameManager.add_collectible_to_savedata(collectible)

	GlobalVariables.set("pitch_black_energized", true)
	GlobalVariables.set("defeated_antonion_vile", true)
	GlobalVariables.set("defeated_panda_vile", true)
	GlobalVariables.set("vile3_defeated", true)
	GlobalVariables.set("vile_palace_defeated", "defeated")
	GlobalVariables.set("copy_sigma_defeated", true)
	GlobalVariables.set("seraph_lumine_defeated", true)
	GlobalVariables.set("red_seen", true)
	GlobalVariables.set("red_defeated", true)
	GlobalVariables.set("serenade_seen", true)
	GlobalVariables.set("serenade_defeated", true)
	GlobalVariables.set("RankSSS", true)
	GlobalVariables.set("player_lives", 9)

	var all_gateway_bosses := ["antonion", "sunflower", "trilobyte", "panda", "mantis", "manowar", "yeti", "rooster"]
	GatewayManager.beaten_bosses = all_gateway_bosses.duplicate()
	GatewayManager.cleared_segments = all_gateway_bosses.duplicate()
	GlobalVariables.set("gateway_bosses_beaten", GatewayManager.beaten_bosses)
	GlobalVariables.set("gateway_segments_cleared", GatewayManager.cleared_segments)

	Savefile.save(Savefile.save_slot)

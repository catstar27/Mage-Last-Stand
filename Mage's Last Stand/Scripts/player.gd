extends CharacterBody2D
#character stat vars
var move_speed := 40.0
var health := 50
var max_health := 50
var last_movement := Vector2.UP
var experience := 0
var level := 1
var collected_exp := 0
var time := 0
var pickup_range := 1
#upgrade vars
var collected_upgrades := []
var upgrade_options := []
var armor := 0
var spell_cooldown := 0.0
var spell_size := 0.0
var additional_attacks := 0
var night_speed := 0.0
var day_speed := 0.0
var night_bonus := 0.0
var day_bonus := 0.0
#ice spear varss
var ice_spear := preload("res://Scenes/ice_spear.tscn")
var ice_spear_ammo := 0
var ice_spear_base_ammo := 0
var ice_spear_attack_speed := 1.5
var ice_spear_level := 0
#tornado vars
var tornado := preload("res://Scenes/tornado.tscn")
var tornado_ammo := 0
var tornado_base_ammo := 0
var tornado_attack_speed := 3.0
var tornado_level := 0
#rune vars
var rune := preload("res://Scenes/rune.tscn")
var rune_ammo := 0
var rune_base_ammo := 0
var rune_attack_speed := 10.0
var rune_level := 0
#rock vars
var rock := preload("res://Scenes/rock.tscn")
var rock_ammo := 0
var rock_base_ammo := 0
var rock_attack_speed := 3.0
var rock_level := 0
#bubble_blast vars
var bubble_blast := preload("res://Scenes/bubble_blast.tscn")
var bubble_blast_ammo := 0
var bubble_blast_base_ammo := 0
var bubble_blast_attack_speed := 5.0
var bubble_blast_level := 0
#javelin vars
var javelin := preload("res://Scenes/javelin.tscn")
var javelin_level := 0
var javelin_ammo := 0
#list of nearby enemies
var enemy_close := []
#onready
@onready var ice_spear_timer := $Attacks/IceSpearTimer
@onready var ice_spear_attack_timer := $Attacks/IceSpearTimer/IceSpearAttackTimer
@onready var tornado_timer := $Attacks/TornadoTimer
@onready var tornado_attack_timer := $Attacks/TornadoTimer/TornadoAttackTimer
@onready var rune_timer := $Attacks/RuneTimer
@onready var rune_attack_timer := $Attacks/RuneTimer/RuneAttackTimer
@onready var rock_timer := $Attacks/RockTimer
@onready var rock_attack_timer := $Attacks/RockTimer/RockAttackTimer
@onready var bubble_blast_timer := $Attacks/BubbleBlastTimer
@onready var javelin_base := $Attacks/JavelinBase
@onready var sprite := $Sprite2D
@onready var light := $PointLight2D
@onready var walk_timer := $WalkTimer
@onready var collect_area := $GrabArea
@onready var exp_bar := $GUILayer/GUI/ExpBar
@onready var level_label := $GUILayer/GUI/ExpBar/LevelLabel
@onready var level_sound := $GUILayer/GUI/LevelUp/LevelUpSound
@onready var upgrade_options_container := $GUILayer/GUI/LevelUp/UpgradeOptions
@onready var level_panel := $GUILayer/GUI/LevelUp
@onready var health_bar := $GUILayer/GUI/HealthBar
@onready var time_label := $GUILayer/GUI/TimeLabel
@onready var collected_weapons_inv := $GUILayer/GUI/CollectedWeapons
@onready var collected_upgrades_inv := $GUILayer/GUI/CollectedUpgrades
@onready var death_panel := $GUILayer/GUI/Death
@onready var label_result := $GUILayer/GUI/Death/ResultLabel
@onready var sound_victory := $GUILayer/GUI/Death/VictorySound
@onready var sound_loss := $GUILayer/GUI/Death/LossSound
@onready var day_night_cycle := get_tree().get_first_node_in_group("light cycle")
@onready var item_options := preload("res://Scenes/item_option.tscn")
@onready var item_container := preload("res://Scenes/inventory_item.tscn")
signal player_death

func _ready():
	upgrade_character("icespear1")
	attack()
	set_exp_bar(experience,calc_exp_req())
	_on_hurt_box_hurt(0,0,0)

func attack():
	ice_spear_timer.wait_time = ice_spear_attack_speed*(1-spell_cooldown)
	if ice_spear_timer.is_stopped():
		ice_spear_timer.start()
	tornado_timer.wait_time = tornado_attack_speed*(1-spell_cooldown)
	if tornado_timer.is_stopped():
		tornado_timer.start()
	rune_timer.wait_time = rune_attack_speed*(1-spell_cooldown)
	if rune_timer.is_stopped():
		rune_timer.start()
	spawn_javelin()
	rock_timer.wait_time = rock_attack_speed*(1-spell_cooldown)
	if rock_timer.is_stopped():
		rock_timer.start()
	bubble_blast_timer.wait_time = bubble_blast_attack_speed*(1-spell_cooldown)
	if bubble_blast_timer.is_stopped():
		bubble_blast_timer.start()

func _physics_process(_delta):
	get_time_bonus()
	movement()
	if bubble_blast_ammo > 0:
		var bubble_blast_attack = bubble_blast.instantiate()
		bubble_blast_attack.global_position = global_position
		bubble_blast_attack.target = get_closest_target()
		bubble_blast_attack.level = bubble_blast_level
		add_child(bubble_blast_attack)
		bubble_blast_ammo -= 1

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	if x_mov > 0:
		sprite.flip_h = true
		light.position = Vector2(-12,-6)
	elif x_mov < 0:
		sprite.flip_h = false
		light.position = Vector2(12,-6)
	velocity = Vector2(x_mov,y_mov).normalized()*move_speed
	if velocity != Vector2.ZERO:
		last_movement = Vector2(x_mov,y_mov)
		if walk_timer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walk_timer.start()
	else:
		sprite.frame = 0
	move_and_slide()

func _on_hurt_box_hurt(damage,_angle,_knockback):
	health -= clamp(damage-armor,1,999)
	health_bar.max_value = max_health
	health_bar.value = health
	if health <= 0:
		death()

func death():
	death_panel.visible = true
	emit_signal("player_death")
	get_tree().paused = true
	var tween = death_panel.create_tween()
	tween.tween_property(death_panel,"position",Vector2(220,50),3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 600:
		label_result.text = "You Win!"
		sound_victory.play()
	else:
		label_result.text = "You Lose!"
		sound_loss.play()

func _on_ice_spear_timer_timeout():
	ice_spear_ammo += ice_spear_base_ammo + additional_attacks
	ice_spear_attack_timer.start()

func _on_ice_spear_attack_timer_timeout():
	if ice_spear_ammo > 0:
		var ice_spear_attack = ice_spear.instantiate()
		ice_spear_attack.global_position = global_position
		ice_spear_attack.target = get_random_target()
		ice_spear_attack.level = ice_spear_level
		add_child(ice_spear_attack)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_attack_timer.start()

func _on_tornado_timer_timeout():
	if tornado_level > 0:
		tornado_ammo += tornado_base_ammo + additional_attacks
		tornado_attack_timer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornado_attack_timer.start()
		else:
			tornado_attack_timer.stop()

func _on_rune_timer_timeout():
	if rune_level > 0:
		rune_ammo += rune_base_ammo + additional_attacks
		rune_attack_timer.start()

func _on_rune_attack_timer_timeout():
	if rune_ammo > 0:
		var rune_attack = rune.instantiate()
		rune_attack.position = position
		rune_attack.level = rune_level
		add_child(rune_attack)
		rune_ammo -= 1
		if rune_ammo > 0:
			rune_attack_timer.start()
		else:
			rune_attack_timer.stop()

func _on_rock_timer_timeout():
	rock_ammo += rock_base_ammo + additional_attacks
	rock_attack_timer.start()

func _on_rock_attack_timer_timeout():
	if rock_ammo > 0:
		var rock_attack = rock.instantiate()
		rock_attack.global_position = global_position
		rock_attack.target = get_closest_target()
		rock_attack.level = rock_level
		add_child(rock_attack)
		rock_ammo -= 1
		if rock_ammo > 0:
			rock_attack_timer.start()

func _on_bubble_blast_timer_timeout():
	bubble_blast_ammo += bubble_blast_base_ammo + additional_attacks

func spawn_javelin():
	if javelin_level > 0:
		var get_javelin_total = javelin_base.get_child_count()
		var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
		while calc_spawns > 0:
			var javelin_spawn = javelin.instantiate()
			javelin_spawn.global_position = global_position
			javelin_base.add_child(javelin_spawn)
			calc_spawns -= 1
		var get_javelins = javelin_base.get_children()
		for i in get_javelins:
			if i.has_method("upgrade_javelin"):
				i.upgrade_javelin()

func get_time_bonus():
	if day_night_cycle.color.get_luminance() < .5:
		if night_bonus < night_speed:
			spell_cooldown += night_speed
			night_bonus += night_speed
		elif night_bonus > night_speed:
			var bonus_correction = night_bonus/night_speed
			night_bonus /= bonus_correction
			spell_cooldown -= night_bonus
	else:
		if night_bonus > 0:
			spell_cooldown -= night_speed
			night_bonus -= night_speed
		elif night_bonus < 0:
			spell_cooldown -= night_bonus
			night_bonus -= night_bonus
	if day_night_cycle.color.get_luminance() >= .5:
		if day_bonus < day_speed:
			spell_cooldown += day_speed
			day_bonus += day_speed
		elif day_bonus > day_speed:
			var bonus_correction = day_bonus/day_speed
			day_bonus /= bonus_correction
			spell_cooldown -= day_bonus
	else:
		if day_bonus > 0:
			spell_cooldown -= day_speed
			day_bonus -= day_speed
		elif day_bonus < 0:
			spell_cooldown -= day_bonus
			day_bonus -= day_bonus

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func get_closest_target():
	if enemy_close.size() > 0:
		var nearest_enemy = enemy_close[0]
		for i in enemy_close:
			if global_position.distance_to(i.global_position) < global_position.distance_to(nearest_enemy.global_position):
				nearest_enemy = i
		return nearest_enemy.global_position
	else:
		return Vector2.UP

func _on_detection_range_body_entered(body):
	if body.is_in_group("enemy"):
		if not enemy_close.has(body):
			enemy_close.append(body)

func _on_detection_range_body_exited(body):
	if body.is_in_group("enemy"):
		if  enemy_close.has(body):
			enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	if area.is_in_group("item"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("item"):
		var gem_exp = area.collected()
		calc_exp(gem_exp)

func calc_exp(gem_exp):
	var required_exp = calc_exp_req()
	collected_exp += gem_exp
	if experience + collected_exp >= required_exp:
		collected_exp -= required_exp-experience
		level += 1
		level_label.text = str("Level ",level)
		experience = 0
		required_exp = calc_exp_req()
		level_up()
	else:
		experience += collected_exp
		collected_exp = 0
	set_exp_bar(experience,required_exp)

func calc_exp_req():
	var exp_cap = level
	if level < 20:
		exp_cap = level*5
	elif level < 40:
		exp_cap = 85*(level - 19)*8
	else:
		exp_cap = 255*(level - 39)*12
	return exp_cap

func set_exp_bar(set_value,set_max_value):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value

func level_up():
	level_sound.play()
	level_panel.visible = true
	var tween = level_panel.create_tween()
	tween.tween_property(level_panel,"position",Vector2(220,50),.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = item_options.instantiate()
		option_choice.item = get_random_item()
		upgrade_options_container.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			ice_spear_level = 1
			ice_spear_base_ammo += 1
		"icespear2":
			ice_spear_level = 2
			ice_spear_base_ammo += 1
		"icespear3":
			ice_spear_level = 3
		"icespear4":
			ice_spear_level = 4
			ice_spear_base_ammo += 2
		"tornado1":
			tornado_level = 1
			tornado_base_ammo += 1
		"tornado2":
			tornado_level = 2
			tornado_base_ammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attack_speed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_base_ammo += 1
		"rune1":
			rune_level = 1
			rune_base_ammo += 1
		"rune2":
			rune_level = 2
		"rune3":
			rune_level = 3
		"rune4":
			rune_level = 4
		"rock1":
			rock_level = 1
			rock_base_ammo += 1
		"rock2":
			rock_level = 1
		"rock3":
			rock_level = 1
		"rock4":
			rock_level = 1
		"bubble_blast1":
			bubble_blast_level = 1
			bubble_blast_base_ammo += 15
		"bubble_blast2":
			bubble_blast_level = 2
		"bubble_blast3":
			bubble_blast_level = 3
			bubble_blast_base_ammo += 15
		"bubble_blast4":
			bubble_blast_level = 4
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			move_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"magnet1","magnet2":
			pickup_range += 1
		"nightdweller1","nightdweller2":
			night_speed += 0.1
		"sunpraiser1","sunpraiser2":
			day_speed += 0.1
		"food":
			health += 20
			health = clamp(health,0,max_health)
	update_inventory(upgrade)
	attack()
	collect_area.scale = Vector2(1,1)*pickup_range
	var option_children = upgrade_options_container.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	level_panel.visible = false
	level_panel.position.x = 800
	get_tree().paused = false
	calc_exp(0)

func get_random_item():
	var upgrade_list = []
	for i in UpgradeDatabase.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDatabase.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDatabase.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDatabase.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				upgrade_list.append(i)
		else:
			upgrade_list.append(i)
	if upgrade_list.size() > 0:
		var random_item = upgrade_list.pick_random()
		upgrade_options.append(random_item)
		return random_item
	else:
		return null

func change_time(time_arg):
	time = time_arg
	var minutes = int(time/60.0)
	var seconds = time % 60
	if minutes < 10:
		minutes = str(0,minutes)
	if seconds < 10:
		seconds = str(0,seconds)
	time_label.text = str(minutes,":",seconds)

func update_inventory(upgrade):
	var get_upgraded_display_names = UpgradeDatabase.UPGRADES[upgrade]["displayname"]
	var get_upgraded_type = UpgradeDatabase.UPGRADES[upgrade]["type"]
	if get_upgraded_type != "item":
		var get_collected_display_names = []
		for i in collected_upgrades:
			get_collected_display_names.append(UpgradeDatabase.UPGRADES[i]["displayname"])
		if not get_upgraded_display_names in get_collected_display_names:
			var new_item = item_container.instantiate()
			new_item.upgrade = upgrade
			match get_upgraded_type:
				"weapon":
					collected_weapons_inv.add_child(new_item)
				"upgrade":
					collected_upgrades_inv.add_child(new_item)

func _on_menu_button_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://Scenes/menu.tscn")

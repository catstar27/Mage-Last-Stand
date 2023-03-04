extends PlayerAttacks

var paths := 1
var attack_speed := 4.0
var target_array := []
var standby_sprite := preload("res://Textures/Items/Weapons/javelin_3_new.png")
var attack_sprite := preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")
@onready var attack_timer := $AttackTimer
@onready var direction_change_timer := $DirectionChangeTimer
@onready var reset_pos_timer := $ResetPosTimer
@onready var attack_sound := $AttackSound

func _ready():
	collision.call_deferred("set","disabled",true)
	_on_reset_pos_timer_timeout()
	upgrade_javelin()

func upgrade_javelin():
	level = player.javelin_level
	match level:
		1:
			speed = 200
			damage = 10
			knockback_amount = 100
			paths = 1
			attack_size = 1.0*(1+player.spell_size)
			attack_speed = 5.0*(1-player.spell_cooldown)
		2:
			speed = 200
			damage = 10
			knockback_amount = 100
			paths = 2
			attack_size = 1.0*(1+player.spell_size)
			attack_speed = 5.0*(1-player.spell_cooldown)
		3:
			speed = 200
			damage = 10
			knockback_amount = 100
			paths = 3
			attack_size = 1.0*(1+player.spell_size)
			attack_speed = 5.0*(1-player.spell_cooldown)
		4:
			speed = 200
			damage = 15
			knockback_amount = 120
			paths = 3
			attack_size = 1.0*(1+player.spell_size)
			attack_speed = 5.0*(1-player.spell_cooldown)
	scale = Vector2(1.0,1.0)*attack_size
	attack_timer.wait_time = attack_speed

func _physics_process(delta):
	if target_array.size() > 0:
		position += angle*speed*delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_difference = global_position - player.global_position
		var return_speed = 20
		if abs(distance_difference.x) > 500 or abs(distance_difference.y) > 500:
			return_speed = 100
		position += player_angle*return_speed*delta
		rotation = global_position.direction_to(player.global_position).angle()+(PI/2)

func _on_attack_timer_timeout():
	add_paths()

func add_paths():
	attack_sound.play()
	emit_signal("destroyed",self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()

func process_path():
	angle = global_position.direction_to(target)
	direction_change_timer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle()+(PI/2)
	tween.tween_property(self,"rotation",new_rotation_degrees,.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _on_direction_change_timer_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			attack_sound.play()
			emit_signal("destroyed",self)
		else:
			enable_attack(false)
	else:
		direction_change_timer.stop()
		attack_timer.start()
		enable_attack(false)

func enable_attack(attack):
	if attack:
		collision.call_deferred("set","disabled",false)
		sprite.texture = attack_sprite
	else:
		collision.call_deferred("set","disabled",true)
		sprite.texture = standby_sprite

func _on_reset_pos_timer_timeout():
	var choose_direction = randi()%4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50

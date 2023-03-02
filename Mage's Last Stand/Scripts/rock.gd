extends PlayerAttacks

func _ready():
	setup()
	can_break = true
	can_despawn = true
	level = player.rock_level
	angle = global_position.direction_to(target)
	rotation = angle.angle()-(3*PI/2)
	match level:
		1:
			speed = 200
			damage = 5
			knockback_amount = 200
			attack_size = 1.0*(1+player.spell_size)
		2:
			speed = 200
			damage = 10
			knockback_amount = 200
			attack_size = 1.0*(1+player.spell_size)
		3:
			speed = 200
			damage = 10
			knockback_amount = 300
			attack_size = 1.0*(1+player.spell_size)
		4:
			speed = 200
			damage = 15
			knockback_amount = 400
			attack_size = 1.0*(1+player.spell_size)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1.5,1.5)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle*speed*delta

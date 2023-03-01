extends PlayerAttacks

func _ready():
	setup()
	can_break = true
	can_despawn = true
	level = player.ice_spear_level
	angle = global_position.direction_to(target)
	rotation = angle.angle()-(3*PI/2)
	match level:
		1:
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0*(1+player.spell_size)
		2:
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0*(1+player.spell_size)
		3:
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0*(1+player.spell_size)
		4:
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0*(1+player.spell_size)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle*speed*delta

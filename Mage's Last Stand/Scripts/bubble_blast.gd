extends PlayerAttacks

var rand_angle

func _ready():
	setup()
	can_break = true
	can_despawn = true
	level = player.bubble_blast_level
	angle = global_position.direction_to(target)
	rand_angle = angle + Vector2(randf_range(-.2,.2),randf_range(-.2,.2))
	rotation = angle.angle()-(3*PI/2)
	match level:
		1:
			hp = 2
			speed = 100
			damage = 1
			knockback_amount = 50
			attack_size = 1.0*(1+player.spell_size)
		2:
			hp = 4
			speed = 100
			damage = 1
			knockback_amount = 50
			attack_size = 1.0*(1+player.spell_size)
		3:
			hp = 4
			speed = 100
			damage = 1
			knockback_amount = 50
			attack_size = 1.0*(1+player.spell_size)
		4:
			hp = 6
			speed = 100
			damage = 2
			knockback_amount = 50
			attack_size = 1.0*(1+player.spell_size)
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(.5,.5)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += rand_angle*speed*delta

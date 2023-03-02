extends PlayerAttacks

var no_loop = 0
var placed_position
@onready var explosion_area := $Explosion
@onready var explosion_collision := $Explosion/ExplosionCollision
var explosion_anim := preload("res://Scenes/death.tscn")

func _ready():
	explosion_collision.call_deferred("set","disabled",true)
	placed_position = player.global_position
	can_despawn = true
	can_break = true
	hp = 99999
	setup()
	level = player.rune_level
	match level:
		1:
			damage = 5
			knockback_amount = 100
			attack_size = 1.0*(1+player.spell_size)
		2:
			damage = 5
			knockback_amount = 100
			attack_size = 1.25*(1+player.spell_size)
		3:
			damage = 5
			knockback_amount = 100
			attack_size = 1.5*(1+player.spell_size)
		4:
			damage = 10
			knockback_amount = 100
			attack_size = 1.75*(1+player.spell_size)
	explosion_area.damage = damage
	explosion_area.knockback_amount = knockback_amount

func _physics_process(_delta):
	global_position = placed_position
	if explosion_area.hp < 99999:
		explode()

func _on_body_entered(body):
	if no_loop == 0:
		if body.is_in_group("enemy"):
			no_loop += 1
			scale = Vector2(1.5,1.5)*attack_size
			sprite.scale /= scale
			explosion_area.angle = global_position.direction_to(player.global_position)*-1.0
			explosion_collision.call_deferred("set","disabled",false)

func explode():
	emit_signal("destroyed",self)
	var boom = explosion_anim.instantiate()
	boom.global_position = global_position
	boom.scale = scale
	get_tree().get_first_node_in_group("enemy_spawner").add_child(boom)
	queue_free()

extends CharacterBody2D
class_name Enemy

var move_speed : float
var health : int
var max_health : int
var knockback_resistance : float
var exp_value : int
var enemy_damage : int
var no_anim : bool
@onready var sprite := get_node("%Sprite2D")
@onready var anim_player := get_node("%AnimationPlayer")
@onready var hurtbox := get_node("%HurtBox")
@onready var hitbox := get_node("%HitBox")
@onready var hurt_sound := get_node("%HurtSound")
@onready var target := get_tree().get_first_node_in_group("player")
@onready var loot_handler := get_tree().get_first_node_in_group("item")
var death_anim := preload("res://Scenes/death.tscn")
var exp_gem := preload("res://Scenes/experience.tscn")
var knockback := Vector2.ZERO
signal destroyed(node)

func setup():
	hitbox.damage = enemy_damage
	hurtbox.hurt.connect(hurt)

func chase():
	knockback = knockback.move_toward(Vector2.ZERO,knockback_resistance)
	var direction = (target.global_position-global_position)
	velocity = direction.normalized()*move_speed
	velocity += knockback
	if velocity != Vector2.ZERO:
		if no_anim != true:
			anim_player.play("walk")
	else:
		anim_player.stop()
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
	move_and_slide()

func hurt(damage,angle,knockback_amount):
	health -= damage
	knockback = angle*knockback_amount
	if health <= 0:
		emit_signal("destroyed",self)
		var death = death_anim.instantiate()
		death.global_position = global_position
		death.scale = scale
		get_parent().call_deferred("add_child",death)
		var new_gem = exp_gem.instantiate()
		new_gem.global_position = global_position
		new_gem.experience = exp_value
		loot_handler.call_deferred("add_child",new_gem)
		queue_free()
	else:
		hurt_sound.play()

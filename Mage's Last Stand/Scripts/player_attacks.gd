extends Area2D
class_name PlayerAttacks

var level : int
var hp : int
var speed : float
var damage : int
var knockback_amount : int
var attack_size : float
var can_break : bool
var can_despawn : bool
var target := Vector2.ZERO
var angle := Vector2.ZERO
var reset_pos := Vector2.ZERO
@onready var sprite := get_node("%Sprite2D")
@onready var collision := get_node("%CollisionShape2D")
@onready var player := get_tree().get_first_node_in_group("player")
signal destroyed(node)

func setup():
	var despawn_timer = get_node("%Timer")
	despawn_timer.timeout.connect(timeout)

func enemy_hit():
	if can_break:
		hp -= 1
		if hp <= 0:
			emit_signal("destroyed",self)
			queue_free()

func timeout():
	if can_despawn:
		emit_signal("destroyed",self)
		queue_free()

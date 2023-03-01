extends Area2D

var damage = 1
@onready var collision = $CollisionShape2D
@onready var disable_hitbox_timer = $DisableHitBoxTimer

func tempdisable():
	collision.call_deferred("set","disable",true)
	disable_hitbox_timer.start()

func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set","disable",false)

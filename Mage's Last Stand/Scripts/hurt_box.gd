extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType := 0
@onready var collision := $CollisionShape2D
@onready var disable_timer := $DisableTimer
var hit_once_array := []
signal hurt(damage,angle,knockback)

func _on_area_entered(area):
	if area.is_in_group("hitbox"):
		if area.damage != null:
			match HurtBoxType:
				0:
					collision.call_deferred("set","disabled",true)
					disable_timer.start()
				1:
					if hit_once_array.has(area) == false:
						hit_once_array.append(area)
						if area.has_signal("destroyed"):
							if not area.is_connected("destroyed",Callable(self,"remove_from_list")):
								area.connect("destroyed",Callable(self,"remove_from_list"))
					else:
						return
				2:
					if area.has_method("tempdisable"):
						area.temp_disable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			if area.get("angle") != null:
				angle = area.angle
			if area.get("knockback_amount") != null:
				knockback = area.knockback_amount
			emit_signal("hurt",damage,angle,knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit()

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)

func remove_from_list(body):
	if hit_once_array.has(body):
		hit_once_array.erase(body)

extends Sprite2D

func _ready():
	$Explode.play("explode")

func _on_explode_animation_finished(_anim_name):
	queue_free()

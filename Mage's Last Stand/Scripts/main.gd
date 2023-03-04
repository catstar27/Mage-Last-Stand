extends Node2D

@onready var canvas_mod := $CanvasModulate

func _ready():
	canvas_mod.color = Color(1,1,1,1)
	var tween = get_tree().create_tween()
	tween.tween_property(canvas_mod,"color",Color(0,0,0,1),60)
	tween.tween_property(canvas_mod,"color",Color(1,1,1,1),60)
	tween.set_loops(5)
	tween.play()

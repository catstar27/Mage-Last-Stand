extends Area2D

@export var experience := 1
var green_sprite := preload("res://Textures/Items/Gems/Gem_green.png")
var red_sprite := preload("res://Textures/Items/Gems/Gem_red.png")
var blue_sprite := preload("res://Textures/Items/Gems/Gem_blue.png")
var target = null
var speed := -0.5
@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D
@onready var audio := $AudioStreamPlayer

func _ready():
	if experience < 5:
		sprite.texture = green_sprite
	elif experience < 25:
		sprite.texture = blue_sprite
	else:
		sprite.texture = red_sprite

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position,speed)
		speed += 2*delta

func collected():
	audio.play()
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return experience

func _on_audio_stream_player_finished():
	queue_free()

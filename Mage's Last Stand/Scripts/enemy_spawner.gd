extends Node2D

@export var spawns: Array[SpawnInfo] = []
@onready var player := get_tree().get_first_node_in_group("player")
var time = 0
signal change_time(time)

func _ready():
	connect("change_time",Callable(player,"change_time"))

func _on_spawn_timer_timeout():
	time += 1
	for i in spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn = i.enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
	emit_signal("change_time",time)

func get_random_position():
	var vpr = get_viewport_rect().size*1.25
	var top_left = Vector2(player.global_position.x - vpr.x/2,player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2,player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2,player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2,player.global_position.y + vpr.y/2)
	var side = ["up","down","left","right"].pick_random()
	var spawn_point_1 = Vector2.ZERO
	var spawn_point_2 = Vector2.ZERO
	match side:
		"up":
			spawn_point_1 = top_right
			spawn_point_2 = top_left
		"down":
			spawn_point_1 = bottom_right
			spawn_point_2 = bottom_left
		"left":
			spawn_point_1 = bottom_left
			spawn_point_2 = top_left
		"right":
			spawn_point_1 = top_right
			spawn_point_2 = bottom_right
	var spawn_pos_x = randf_range(spawn_point_1.x,spawn_point_2.x)
	var spawn_pos_y = randf_range(spawn_point_1.y,spawn_point_2.y)
	return Vector2(spawn_pos_x,spawn_pos_y)

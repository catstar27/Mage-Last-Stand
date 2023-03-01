extends Enemy

func _ready():
	enemy_damage = 2
	exp_value = 3
	knockback_resistance = 3.5
	max_health = 20
	health = 20
	move_speed = 28
	setup()

func _physics_process(_delta):
	chase()

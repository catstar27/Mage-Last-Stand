extends Enemy

func _ready():
	enemy_damage = 1
	exp_value = 1
	knockback_resistance = 3.5
	max_health = 10
	health = 10
	move_speed = 20
	setup()

func _physics_process(_delta):
	chase()

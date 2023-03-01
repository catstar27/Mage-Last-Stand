extends Enemy

func _ready():
	enemy_damage = 5
	exp_value = 5
	knockback_resistance = 10
	max_health = 100
	health = 100
	move_speed = 16
	setup()

func _physics_process(_delta):
	chase()

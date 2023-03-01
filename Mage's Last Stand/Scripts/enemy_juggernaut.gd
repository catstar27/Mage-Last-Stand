extends Enemy

func _ready():
	enemy_damage = 8
	exp_value = 100
	knockback_resistance = 20
	max_health = 300
	health = 300
	move_speed = 40
	setup()

func _physics_process(_delta):
	chase()

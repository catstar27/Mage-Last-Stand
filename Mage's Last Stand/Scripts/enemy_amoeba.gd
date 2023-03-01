extends Enemy

func _ready():
	no_anim = true
	enemy_damage = 20
	exp_value = 1
	knockback_resistance = 99999
	max_health = 99999
	health = 99999
	move_speed = 150
	setup()

func _physics_process(_delta):
	chase()

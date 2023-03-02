extends Area2D

var damage
var knockback_amount
var hp = 99999
var angle

func enemy_hit():
	hp -= 1

extends Node

var max_health = 100
var current_health = max_health

func _ready():
	$PlayerHealth.max_value = max_health
	$PlayerHealth.value = current_health

func take_damage(amount):
	current_health = clamp(current_health - amount, 0, max_health)
	$PlayerHealth.value = current_health
	if current_health == 0:
		print("Player is defeated!")

func heal(amount):
	current_health = clamp(current_health + amount, 0, max_health)
	$PlayerHealth.value = current_health

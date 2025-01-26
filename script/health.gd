class_name Health
extends Node


const MAX_HEALTH = 100.0
const MAX_UI_BUBBLE = 10.0
const DRAIN_SPEED := 1.0

var _health = 100.0


func get_percent():
	print(_health)
	return _health / MAX_HEALTH

func get_bubble_count():
	var percent = get_percent()
	return floor(percent * MAX_UI_BUBBLE)

func _process(delta):
	_health -= delta * DRAIN_SPEED

func is_dead():
	return _health <= 0.0

func drain(amount: float):
	_health -= amount

func fill(amount: float):
	_health += amount
	_health = clamp(_health, 0, 100)

func restart():
	_health = MAX_HEALTH

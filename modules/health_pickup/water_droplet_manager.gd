extends Node3D

const HEALTH_PICKUP = preload("res://modules/health_pickup/health_pickup.tscn")
@onready var timer: Timer = $Timer
@onready var starting_pickup: Node3D = $HealthPickup

var spawn_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_position = starting_pickup.position

func make_droplet():
	var instance = HEALTH_PICKUP.instantiate()
	add_child(instance)
	instance.position = spawn_position
	instance.picked_up.connect(droplet_picked)
	
func droplet_picked():
	timer.start()

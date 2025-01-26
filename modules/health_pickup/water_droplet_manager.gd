extends Node3D

const HEALTH_PICKUP = preload("res://modules/health_pickup/health_pickup.tscn")
@onready var timer: Timer = $Timer
@onready var starting_pickup: Node3D = $HealthPickup

var spawn_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_position = starting_pickup.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func make_droplet():
	print_debug("Droplet Made")
	var instance = HEALTH_PICKUP.instantiate()
	add_child(instance)
	instance.position = spawn_position
	print_debug(instance.position)
	instance.picked_up.connect(droplet_picked)
	
func droplet_picked():
	print('Timer Started')
	timer.start()

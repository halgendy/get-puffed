extends CharacterBody3D

var patrol_points#: Array[Marker3D]
var patrol_points_flags: Array[bool]
var next_point_index
@export var speed: float
@export var wait_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = 5.0
	wait_timer = 5.0
	patrol_points = self.get_parent().find_child("Points").get_children()
	
	for i in patrol_points:
		patrol_points_flags.append(false)
	
	#var test = patrol_points.get_children()
	
	print(patrol_points)
	print(patrol_points_flags)
	#print(test)
	#print(typeof(test))
	
	print(patrol_points[1].position)
	
	next_point_index = 0
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _physics_process(delta: float) -> void:
	
	position = position.move_toward(patrol_points[next_point_index].position, delta * speed)
	
	if position == patrol_points[next_point_index].position:
		print("reached start")
		await get_tree().create_timer(wait_timer).timeout
		print("DONE")
		pass

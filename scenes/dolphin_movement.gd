extends CharacterBody3D

# an array of references to the Marker3D objects that denote each patrol checkpoint for the dolphin
var patrol_points#: Array[Marker3D]

# the current point the dolphin is waiting at, or if it's walking, the last point the dolphin was at
var current_point_index

var next_point_index

var is_returning: bool = false

# simple bool to check if dolphin should be walking or pausing at a patrol point
var walking: bool = true

# movement speed of the dolphin
@export var speed: float

# how long the dolphin will wait at a patrol point before moving again
@export var wait_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = 3.0
	wait_timer = 5.0
	patrol_points = self.get_parent().find_child("PatrolPoints").get_children()
	
	# var test = patrol_points.get_children()
	
	print(patrol_points)
	# print(test)
	# print(typeof(test))
	
	# print(patrol_points[1].position)
	
	print(patrol_points.size())
	
	current_point_index = 0
	next_point_index = 1
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass



func _physics_process(delta: float) -> void:
	
	if walking == false:
		# currently waiting at a point
		look_at(patrol_points[next_point_index].position)
		pass
	else:
		position = position.move_toward(patrol_points[next_point_index].position, delta * speed)
		print("walk")
		
		if position == patrol_points[next_point_index].position:
			walking = false
			current_point_index = next_point_index
			_reached_point()

func _on_timer_timeout() -> void:
	# timer ended, we need to start walking
	walking = true
	print("=================TIMER OUT===========")
	
func _reached_point() -> void:
	
	if is_returning:
		if current_point_index == 0:
			is_returning = false
			next_point_index = current_point_index + 1
		else:
			next_point_index = current_point_index - 1
		
	elif !is_returning:
		print("not returning")
		if current_point_index == patrol_points.size() - 1:
			print("go back")
			is_returning = true
			next_point_index = current_point_index - 1
		else:
			next_point_index = current_point_index + 1
	
	print("current point = ", current_point_index)
	print("next point = ", next_point_index)
	print("--------------------------")
	
	$Timer.start(wait_timer)
	pass

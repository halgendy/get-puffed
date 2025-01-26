extends CharacterBody3D

# an array of references to the Marker3D objects that denote each patrol checkpoint for the dolphin
var patrol_points#: Array[Marker3D]

# the current point the dolphin is waiting at, or if it's walking, the last point the dolphin was at
var current_point_index

var next_point_index

var is_returning: bool = false

# simple bool to check if dolphin should be walking or pausing at a patrol point
var walking: bool = false # set to false initially if you want the dolphin to just never move, for debugging

# bool that tracks if the dolphin is in chase mode (walking will be false in that case and this will become true)
# otherwise, flip them
var chasing: bool = true

var spotlight_detector # spotlight Area3D collider for Pedro trigger
var spotlight_object # the SpotLight3D object itself
var spotlight_original_color: Color = Color(0, 255, 255)
var spotlight_alert_color: Color = Color(255, 0, 0)

# 0 = no sensitivity ... 1 = instant sensitivity (insta-death)
var spotlight_sensitivity: float = 0.3

# movement speed of the dolphin when patrolling
@export var patrol_speed: float

# movement speed of the dolphin when it's spotted Pedro and is chasing
@export var chase_speed: float

# how fast the dolphin turns, in euler angles
@export var turn_speed: float

# how long the dolphin will wait at a patrol point before moving again
@export var wait_timer: float

# The NavigationAgent3D that handles navigating
@onready var nav: NavigationAgent3D = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	patrol_speed = 30.0
	wait_timer = 2.0
	turn_speed = 5.0
	chase_speed = 10.0
	
	patrol_points = self.get_parent().find_child("PatrolPoints").get_children()
	spotlight_detector = find_child("SpotlightCollision")
	spotlight_object = find_child("SpotLight3D")
	
	# var test = patrol_points.get_children()
	
	print(patrol_points)
	print("============Node: ", get_node("/root").get_child(0).find_child("Player"))
	print("Spotlight: ", spotlight_detector)
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
	
	nav.target_position = get_node("/root").get_child(0).find_child("Player").position
	# print("TARGET = ", nav.target_position)
	
	var direction = nav.get_next_path_position() - self.position
	direction = direction.normalized()
	
	var goal_angle = atan2(position.x - nav.target_position.x, position.z - nav.target_position.z)
	rotation.y = lerp_angle(rotation.y, goal_angle, turn_speed * delta * 2)
	
	velocity = velocity.lerp(direction * chase_speed, 10 * delta)
	
	if move_and_slide():
		print("OW")
	
	_check_spotlight(delta)
	
	if walking == false:
		# currently waiting at a point
		_turn_towards_next_point(delta)
		pass
	else:
		position = position.move_toward(patrol_points[next_point_index].position, delta * patrol_speed)
		# print("walk")
		
		if position == patrol_points[next_point_index].position:
			walking = false
			current_point_index = next_point_index
			_reached_point()

# a timer of length wait_timer (sec) starts when the rolphin is in patrol mode (walking) and reaches a patrol point
func _on_timer_timeout() -> void:
	# timer ended, we need to start walking
	walking = true
	print("=================TIMER OUT===========")
	look_at(patrol_points[next_point_index].position)

# called when the dolphin reaches a predesignated patrol point in its patrol path (patrol_points[])
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

# helper function to turn the dolphin towards the next patrol point
# called when the dolphin reaches a designated patrol point
func _turn_towards_next_point(delta: float) -> void:
	# x / z, in radians
	var goal_angle = atan2(position.x - patrol_points[next_point_index].position.x, position.z - patrol_points[next_point_index].position.z)
	
	rotation.y = lerp_angle(rotation.y, goal_angle, turn_speed * delta)
	
# helper function that handles the spotlight detecting whether or not Pedro is in its detection area
func _check_spotlight(delta: float) -> void:
	if spotlight_detector.overlaps_body(get_node("/root").get_child(0).find_child("Player")):
		print("Found Pedro")
		spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_alert_color, spotlight_sensitivity * delta)
	else:
		spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_original_color, spotlight_sensitivity * delta)

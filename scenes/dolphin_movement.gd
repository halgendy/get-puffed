extends CharacterBody3D

# an array of references to the Marker3D objects that denote each patrol checkpoint for the dolphin
var patrol_points#: Array[Marker3D]

# the current point the dolphin is waiting at, or if it's walking, the last point the dolphin was at
var current_point_index

var next_point_index

var is_returning: bool = false

# simple bool to check if dolphin should be walking or pausing at a patrol point
var walking: bool = false # set to false if you want the dolphin to just never move, for debugging

var spotlight_detector
var spotlight_object
var spotlight_original_color: Color = Color(0, 255, 255)
var spotlight_alert_color: Color = Color(255, 0, 0)

# movement speed of the dolphin
@export var speed: float

# how fast the dolphin turns, in euler angles
@export var turn_speed: float

# how long the dolphin will wait at a patrol point before moving again
@export var wait_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = 30.0
	wait_timer = 2.0
	turn_speed = 5.0
	
	patrol_points = self.get_parent().find_child("PatrolPoints").get_children()
	spotlight_detector = find_child("SpotlightCollision")
	spotlight_object = find_child("SpotLight3D")
	
	# var test = patrol_points.get_children()
	
	print(patrol_points)
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
	
	if spotlight_detector.has_overlapping_bodies():
		print("Found Pedro")
		spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_alert_color, 0.3 * delta)
	else:
		spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_original_color, 0.3 * delta)
	
	if walking == false:
		# currently waiting at a point
		_turn_towards_next_point(delta)
		pass
	else:
		position = position.move_toward(patrol_points[next_point_index].position, delta * speed)
		# print("walk")
		
		if position == patrol_points[next_point_index].position:
			walking = false
			current_point_index = next_point_index
			_reached_point()

func _on_timer_timeout() -> void:
	# timer ended, we need to start walking
	walking = true
	print("=================TIMER OUT===========")
	look_at(patrol_points[next_point_index].position)
	
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

func _turn_towards_next_point(delta: float) -> void:
	# x / z, in radians
	var goal_angle = atan2(position.x - patrol_points[next_point_index].position.x, position.z - patrol_points[next_point_index].position.z)
	
	rotation.y = lerp_angle(rotation.y, goal_angle, turn_speed * delta)
	

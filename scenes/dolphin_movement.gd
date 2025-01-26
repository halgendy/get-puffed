extends CharacterBody3D

# a reference to the Player Node
var player_node

# an array of references to the Marker3D objects that denote each patrol checkpoint for the dolphin
var patrol_points#: Array[Marker3D]

# the current point the dolphin is waiting at, or if it's walking, the last point the dolphin was at
var current_point_index
# the index of the next point the dolphin will work its way towards while patrolling
var next_point_index

# a flag to check which "direction" the dolphin is currently moving in on its patrol path
# false = it's working its way towards patrol_point[last]
# true = it's working its way towards patrol_point[0]
var is_returning: bool = false

# enum tracking 3 states for the dolphin.
# WAITING = pausing and turning at a designated patrol point
# WALKING = walking towards the next patrol point in its path
# CHASING = Pedro spent long enough in the dolphin's vision that the dolphin is now on the hunt
enum {MODE_WAITING, MODE_WALKING, MODE_CHASING}
# current_state will have one of these 3 enum values, tracking which state the dolphin is in
var current_state

var spotlight_detector # spotlight Area3D collider for Pedro trigger
var spotlight_object # the SpotLight3D object itself
var spotlight_original_color: Color = Color(0, 255, 255) # a light cyan blue
var spotlight_alert_color: Color = Color(255, 0, 0) # pure red

# 0 = no sensitivity ... 1 = instantly changes color
# affects how fast the spotlight changes from original_color to alert_color
@export var spotlight_sensitivity: float = 0.3

# float value with range [0, 255] determining how red the spotlight can get before dolphin starts chasing
@export var chase_activation_threshold: float = 50.0

# float value with range [0, 255] determining at what point the dolphin starts to drain Pedro's HP
@export var hp_drain_threshold: float = 150.0

# movement speed of the dolphin when patrolling
@export var patrol_speed: float

# movement speed of the dolphin when in chase mode
@export var chase_speed: float

# how fast the dolphin turns, higher = turns more quickly
@export var turn_speed_patrol: float

# how fast the dolphin turns while in chase mode, higher = turns more quickly
@export var turn_speed_chase: float

# how long the dolphin will wait (seconds) at a patrol point before moving again
@export var wait_timer_patrol: float

@export var speech_audio: AudioStream
@export var dolphin_music: AudioStream

# bool for ensuring the timer only starts one instance
var wait_timer_on: bool

# The NavigationAgent3D that handles navigating
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var speech_audio_player: AudioStreamPlayer3D = $SpeechAudio
@onready var music_audio_player: AudioStreamPlayer3D = $MusicAudio
@onready var speech_timer: Timer = $SpeechAudioPlayer/SpeechTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#speech_audio_player.stream = speech_audio
	#music_audio_player.stream = dolphin_music
	#speech_timer.wait_time = randi_range(20, 30)
	patrol_points = self.get_parent().find_child("PatrolPoints").get_children()
	spotlight_detector = find_child("SpotlightCollision")
	spotlight_object = find_child("SpotLight3D")
	
	player_node = get_node("/root").get_child(1).find_child("Player")
	
	print("Patrol points:", patrol_points)
	print("============Player: ", player_node)
	print("Spotlight: ", spotlight_detector)
	
	print("Number of patrol points: ", patrol_points.size())
	
	current_point_index = 0
	next_point_index = 1
	
	current_state = MODE_WALKING
	#music_audio_player.play()
	#speech_timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass



func _physics_process(delta: float) -> void:
	
	# force x and z axis rotation lock
	rotation.x = 0
	rotation.z = 0
	
	_determine_state(delta)
	
	print("LOOP_START state = ", current_state)
	
	if current_state == MODE_CHASING:
		_chase(delta)
	elif current_state == MODE_WALKING:
		_walk(delta)
	elif current_state == MODE_WAITING:
		_wait(delta)

# a timer of length wait_timer (sec) starts when the rolphin is in patrol mode (walking) and reaches a patrol point
func _on_wait_timer_timeout() -> void:
	# timer ended, we need to start walking
	current_state = MODE_WALKING
	wait_timer_on = false
	print("=================TIMER OUT===========")
	look_at(patrol_points[next_point_index].position)
	# position.z += 10e

# called when the dolphin reaches a predesignated patrol point in its patrol path (patrol_points[])
func _reached_point() -> void:
	
	if !wait_timer_on:
		$WaitTimer.start(wait_timer_patrol)
		current_state = MODE_WAITING
		wait_timer_on = true
		
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
	pass

# helper function to turn the dolphin towards the next patrol point
# called when the dolphin reaches a designated patrol point
func _turn_towards_target(delta: float, target: Vector3, turn_sens: float) -> void:
	# x / z, in radians
	
	var goal_angle = atan2(position.x - target.x, position.z - target.z)
	rotation.y = lerp_angle(rotation.y, goal_angle, turn_sens * delta)
	
# helper function that handles the spotlight detecting whether or not Pedro is in its detection area
# also changes the spotlight color
func _check_spotlight(delta: float) -> void:
	
	print("inside check_spotlight() ", spotlight_detector.overlaps_body(player_node))
	
	# print(spotlight_object.light_color)
	if spotlight_detector.overlaps_body(player_node):
		print("Found Pedro")
		spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_alert_color, spotlight_sensitivity * delta)
	else:
		spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_original_color, spotlight_sensitivity * delta)

# function that checks the spotlight status and determines which state the dolphin should be in
func _determine_state(delta) -> void:
	_check_spotlight(delta)
	
	#if $WaitTimer.time_left > 0 and spotlight_object.light_color.r <= chase_activation_threshold:
			#current_state = MODE_WAITING
			#print("#########other wait")
			#return
	
	if spotlight_object.light_color.r > 150:
		player_node.health.drain(delta * 10)
	
	if spotlight_object.light_color.r > chase_activation_threshold:
		current_state = MODE_CHASING
		print("====CHASE TIME")
	else:
		if position == patrol_points[next_point_index].position:
			print("--------------reached point")
		
			current_point_index = next_point_index
			_reached_point()
			print("WAIT TIME")
		else:
			current_state = MODE_WALKING
			print("WALK TIME")
	pass

func _chase(delta: float) -> void:
	nav.target_position = player_node.position
	
	var direction = nav.get_next_path_position() - self.position
	direction = direction.normalized()
	
	_turn_towards_target(delta, nav.target_position, turn_speed_chase)
	
	velocity = velocity.lerp(direction * chase_speed, 10 * delta)
	
	if move_and_slide():
		# print("OW")
		pass

func _walk(delta: float) -> void:
	position = position.move_toward(patrol_points[next_point_index].position, delta * patrol_speed)
	_turn_towards_target(delta, patrol_points[next_point_index].position, turn_speed_patrol)
		# print("walk")

func _wait(delta: float) -> void:
	# currently waiting at a point
	print("============WAIT")
	_turn_towards_target(delta, patrol_points[next_point_index].position, turn_speed_patrol)


#func _on_spotlight_collision_body_entered(body: Node3D) -> void:
	#if body is Player:
		#spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_alert_color, spotlight_sensitivity )
	#
	#pass # Replace with function body.
#
#
#func _on_spotlight_collision_body_exited(body: Node3D) -> void:
	#if body is Player:
		#spotlight_object.light_color = spotlight_object.light_color.lerp(spotlight_original_color, spotlight_sensitivity)	
	#pass # Replace with function body.


func _on_speech_timer_timeout() -> void:
	speech_audio_player.play()
	speech_timer.wait_time = randi_range(20, 30)
	speech_timer.start()

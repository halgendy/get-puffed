class_name Player
extends RigidBody3D

# States
@export var can_move: bool = true
@export var checkpoint: Vector3 = position
@export var movement_audio: AudioStream

# Camera Parameters
var default_mouse_mode = Input.MOUSE_MODE_HIDDEN
var pause_mouse_mode = Input.MOUSE_MODE_VISIBLE
var jump_trauma = 0.5
var sprint_trauma = 0.2
var walk_trauma = 0.1
var stop_trauma = 0.5
const NUM_BREADCRUMBS = 50
var breadcrumbs: Array = []
var camera_current_breadcrumb = position

# Movement Parameters
const walk_acceleration: float = 100 # meters / second^2
const jump_velocity: float = 4.5 # meters / second
const walk_velocity: float = 0.5 # meters / second
const sprint_factor: float = 2
const WATER_BUBBLE_BURST = preload("res://sfx/WaterBubbleBurst.wav")
# Movement Input Parameters
var mouse_sensitivity := 0.001
var min_pitch := -60
var max_pitch := 60

var twist_input := 0.0
var pitch_input := 0.0

# Player Objects
#@onready var camera := $TwistPivot/PitchPivot/Camera
@export var camera: Node3D
@onready var health: Health = $Health
@onready var ui: CanvasLayer = $UI

# Character Properties
@onready var character_height = $CollisionShape3D.shape.radius
@onready var player_mass: float = self.mass


# Called when the node enters the scene tree for the **first time.**
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("walk")


func respawn():
	position = checkpoint
	health.restart()
	self.reset_physics_interpolation()
	self.angular_velocity = Vector3.ZERO
	self.linear_velocity = Vector3.ZERO
	camera_current_breadcrumb = position

var last_walk_dir := Vector3.ZERO

# Called every frame. (delta: float) is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health.is_dead():
		AudioManager.play_audio(WATER_BUBBLE_BURST)
		respawn()
	
	var mapped_scalar = remap(health.get_percent(), 0.0, 1.0, 1.65/3.0, 5.0/3.0)
	$CSGSphere3D.radius = mapped_scalar
	$CollisionShape3D.shape.radius = mapped_scalar
	ui.kill_bubbles()
	ui.set_bubbles(health.get_bubble_count())
	mass = health.get_percent() + 1
	
	var walk_force = Vector3.ZERO
	if can_move:
		# Get direction player wants to move in based on input
		# For get_axis: returns -1.0 if first, +1.0 if second, 0.0 if none OR both
		var cardinal_direction := Vector3.ZERO
		cardinal_direction.x = Input.get_axis("move_left", "move_right")
		cardinal_direction.z = Input.get_axis("move_forward", "move_back")
		if cardinal_direction.z > 0: # animation stuff
			$Sprite3D.show()
			$Sprite3D2.hide()
		else:
			$Sprite3D.hide()
			$Sprite3D2.show()
		
		var camera_y_rot = camera.rotation.y
		
		# Calculate movement direction relative to twist_pivot | normalized to fix diagonal
		# Use the mass and acceleration to calculate force | F = ma
		var directional_vector: Vector3 = cardinal_direction.normalized().rotated(Vector3.UP, camera_y_rot)
		if directional_vector != Vector3.ZERO:
			last_walk_dir = directional_vector

		walk_force = directional_vector * walk_acceleration
	
	# Damp the player / apply net movement
	var damp_acceleration = walk_acceleration * walk_velocity / 3.0
	var damp_force = Vector3(linear_velocity.x, 0, linear_velocity.z) * damp_acceleration 
	
	# For future reference, apply_central force based on time already, so no * delta
	apply_central_force((walk_force - damp_force) * mass)
	#apply_torque((walk_force - damp_force) * mass * 0.2)
	#angular_velocity *= 0.99

	
	#camera.rotate_y((desired_rotation - camera.rotation.y) * 0.05)
	
	if Input.is_action_just_pressed("dash") and last_walk_dir != Vector3.ZERO:
		print(health.get_percent())
		if health.get_percent() > 0.25:
			apply_central_force(last_walk_dir * 1200.0 * mass)
			health.drain(20.0)
			AudioManager.play_audio(movement_audio)
	
	#print(breadcrumbs)
	var desired_position = _active_crumb()

	if desired_position:
		# distance squared to the player
		var distance_squared = camera.global_position.distance_squared_to(global_position)
		
		# speed based of distance
		var min_speed = 1.0
		var max_speed = 10.0
		var speed = lerp(min_speed, max_speed, clamp(distance_squared / 100, 0.0, 1.0))

		# smooth move to next breadcrumb
		var velocity = (desired_position - camera.global_position).normalized() * speed * delta
		camera.global_position += velocity
	else:
		# idle if close enough to player
		if camera.global_position.distance_to(global_position) > 5:
			return  # Do nothing; the camera stays in place

	# always
	camera.look_at(global_position)


# change to get closest
func _active_crumb():
	# find the next breadcrumb in the list
	while breadcrumbs.size() > 0:
		var crumb = breadcrumbs[0]
		if camera.global_position.distance_to(crumb) < 2:  # if the camera "visits" the crumb
			breadcrumbs.remove_at(0)  # Remove it
		else:
			return crumb  # first unvisited crumb
	return null  # no crumbs are left, return null

func _on_breadcrumb_timer_timeout():
		# new breadcrumb if the player has moved at least 2 units from the last one
	if breadcrumbs.size() == 0 or global_position.distance_to(breadcrumbs[-1]) > 5:
		if breadcrumbs.size() >= NUM_BREADCRUMBS:
			breadcrumbs.remove_at(0)  # remove oldest breadcrumb to keep the list size
		breadcrumbs.append(global_position)

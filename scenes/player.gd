extends RigidBody3D

# States
@export var can_move: bool = true
@export var sprinting: bool = false

# Camera Parameters
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var pause_mouse_mode = Input.MOUSE_MODE_VISIBLE
var jump_trauma = 0.5
var sprint_trauma = 0.2
var walk_trauma = 0.1
var stop_trauma = 0.5

# Movement Parameters
const walk_acceleration: float = 50 # meters / second^2
const jump_velocity: float = 4.5 # meters / second
const walk_velocity: float = 0.5 # meters / second
const sprint_factor: float = 2 

# Movement Input Parameters
var mouse_sensitivity := 0.001
var min_pitch := -60
var max_pitch := 60

var twist_input := 0.0
var pitch_input := 0.0

# Player Objects
@onready var camera := $TwistPivot/PitchPivot/Camera

# Character Properties
@onready var character_height = $CollisionShape3D.shape.radius
@onready var player_mass: float = self.mass

# Called when the node enters the scene tree for the **first time.**
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. (delta: float) is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var walk_force = Vector3.ZERO
	if can_move:
		# Get direction player wants to move in based on input
		# For get_axis: returns -1.0 if first, +1.0 if second, 0.0 if none OR both
		var cardinal_direction := Vector3.ZERO
		cardinal_direction.x = Input.get_axis("move_left", "move_right")
		cardinal_direction.z = Input.get_axis("move_forward", "move_back")
		
		# Calculate movement direction relative to twist_pivot | normalized to fix diagonal
		# Use the mass and acceleration to calculate force | F = ma
		var directional_vector: Vector3 = self.global_basis * cardinal_direction.normalized()

		walk_force = directional_vector * walk_acceleration
	
	# Damp the player / apply net movement
	var damp_acceleration = walk_acceleration * walk_velocity
	var damp_force = Vector3(linear_velocity.x, 0, linear_velocity.z) * damp_acceleration 
	
	# For future reference, apply_central force based on time already, so no * delta
	apply_central_force((walk_force - damp_force) * player_mass)

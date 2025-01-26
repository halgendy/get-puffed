extends Node3D

signal picked_up
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const JUMP_IN_PUDDLE = preload("res://sfx/JumpInPuddle.wav")

func _ready() -> void:
	animation_player.play("idle")
func _on_pickup_box_body_entered(body: Node3D) -> void:
	if body is Player:
		AudioManager.play_audio(JUMP_IN_PUDDLE)
		picked_up.emit()
		body.health.fill(30)
		queue_free()

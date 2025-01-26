extends Node3D

signal picked_up

func _on_pickup_box_body_entered(body: Node3D) -> void:
	if body is Player:
		picked_up.emit()
		body.health.fill(30)
		queue_free()

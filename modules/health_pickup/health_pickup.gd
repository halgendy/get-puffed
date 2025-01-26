extends Node3D


func _on_pickup_box_body_entered(body: Node3D) -> void:
	if body is Player:
		body.health.fill(30)
		queue_free()

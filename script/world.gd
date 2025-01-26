@tool
extends Node3D


func _on_area_3d_body_entered(body):
	if body is Player:
		print("you win")
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://main.tscn")

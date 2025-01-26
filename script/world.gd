@tool
extends Node3D


func _on_area_3d_body_entered(body):
	if body is Player:
		print("you win")
		await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_file("res://main.tscn")


func _ready():
	var front_room = $"front room with collisions"
	var nodes = [$"WholeScene (5)", front_room.get_node("display"), front_room.get_node("display1"), front_room.get_node("group7")]
	for node in nodes:
		for light in node.get_children():
			if light is Light3D:
				light.light_energy = 0.3

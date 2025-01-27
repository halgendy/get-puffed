extends Control


## Called when the node enters the scene tree for the first time.
#func _ready():
	#var camera: Camera3D = $scene/front_room_Model_folder/render_camera
	#camera.current = true
	#var animator: AnimationPlayer = $scene/AnimationPlayer
	#animator.play("Take 001")


func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

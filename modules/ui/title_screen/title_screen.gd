extends Control

#var tutorial_screen = preload("res://modules/ui/extras_menu/tutorial_screen.gd")
const GET_PUFFED_BASE = preload("res://music/get puffed base.wav")

func _on_start_button_pressed() -> void:
	AudioManager.play_music(GET_PUFFED_BASE)
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_tutorial_pressed() -> void:
	%MainElements.hide()
	%TutorialScreen.show()

func _on_tutorial_screen_hidden() -> void:
	%MainElements.show()

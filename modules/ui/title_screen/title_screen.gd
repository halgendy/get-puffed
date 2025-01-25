extends Control

#var tutorial_screen = preload("res://modules/ui/extras_menu/tutorial_screen.gd")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_tutorial_pressed() -> void:
	%MainElements.hide()
	%TutorialScreen.show()

func _on_tutorial_screen_hidden() -> void:
	%MainElements.show()

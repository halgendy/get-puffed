extends Control

var tutorial_screen = preload("res://modules/UI/ExtrasMenu/tutorial_screen.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/world.tscn"))

func _on_tutorial_pressed() -> void:
	%MainElements.hide()
	%TutorialScreen.show()

func _on_tutorial_screen_hidden() -> void:
	%MainElements.show()

extends Control

const YOU_WIN_ = preload("res://sfx/YouWin!.wav")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_audio(YOU_WIN_)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

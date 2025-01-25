extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if !get_tree().paused:
			get_tree().paused = true
			show()

		else:
			hide()
			get_tree().paused = false

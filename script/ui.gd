@tool
extends CanvasLayer

const BUBBLE = preload("res://scenes/bubble.tscn")
const UI_BUBBLE_POP = preload("res://sfx/UIBubblePop.wav")

@export var bubble_image: PackedScene

@onready var bubble_ui: Control = $Control/BubbleUI
var playing_pop := false

func _ready():
	set_bubbles(10)
	
func kill_bubbles():
	bubble_ui.bubbles -= 1
	#var instance = BUBBLE.instantiate()
	#bubble_ui.bubblesRect.add_child(instance)
	#instance.position = Vector2((bubble_ui.bubbles + 1) * 24, 0)
	#instance.drain()
	
func pop_finished():
	playing_pop = false
	
func set_bubbles(amount: int):
	if !playing_pop and bubble_ui.bubbles >= amount:
		AudioManager.play_audio(UI_BUBBLE_POP)
		playing_pop = true
		get_tree().create_timer(1.88).timeout.connect(pop_finished)
	bubble_ui.bubbles = amount
		

		

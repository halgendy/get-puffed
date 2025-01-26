@tool
extends CanvasLayer

const BUBBLE = preload("res://scenes/bubble.tscn")

@export var bubble_image: PackedScene

@onready var bubble_ui: Control = $Control/BubbleUI


func _ready():
	set_bubbles(10)
	
func kill_bubbles():
	bubble_ui.bubbles -= 1
	var instance = BUBBLE.instantiate()
	bubble_ui.bubblesRect.add_child(instance)
	instance.position = Vector2((bubble_ui.bubbles + 1) * 24, 0)
	instance.drain()

func set_bubbles(amount: int):
	bubble_ui.bubbles = amount
		

		

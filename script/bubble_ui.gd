extends Control

var bubbles = 10: 
	set(value):
		bubbles = clamp(value, 0, max_bubbles)
		update_bubble_count()
			
var max_bubbles = 10:
	set(value):
		max_bubbles = max(value, 1)
		self.hearts = min(bubbles, max_bubbles)
		update_bubble_count()

@onready var bubblesRect = $Bubbles

func update_bubble_count():
	if bubblesRect != null:
		bubblesRect.size.x = bubbles * 24

func _ready() -> void:
	update_bubble_count()

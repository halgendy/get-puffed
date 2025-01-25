@tool
extends CanvasLayer

@export var bubble_image: PackedScene

@onready var bubble_container = $Control/HBoxContainer

func _ready():
	set_bubbles(10)

func set_bubbles(amount: int):
	var current_bubble_count = bubble_container.get_child_count()
	var delta_bubbles = amount - current_bubble_count
	for i in range(delta_bubbles):
		# add
			var bubble := bubble_image.instantiate()
			bubble_container.add_child(bubble)
	if delta_bubbles < 0:
		for i in range(abs(delta_bubbles)):
			# delete
			bubble_container.get_child(i).queue_free()
		

@tool
extends CanvasLayer

@export var bubble_image: PackedScene

@onready var bubble_container = $Control/HBoxContainer

func _ready():
	set_bubbles(10)

func kill_bubbles():
	for bubble in bubble_container.get_children():
		bubble.queue_free()

func set_bubbles(amount: int):
	var current_bubble_count = len(bubble_container.get_children().filter(func(x): return not x.drained))
	var delta_bubbles = amount - current_bubble_count
	for i in range(delta_bubbles):
		# add
		if current_bubble_count + i < 10 and bubble_container.get_child_count() >= 10:
			bubble_container.get_child(current_bubble_count + i).show()
		else:
			var bubble := bubble_image.instantiate()
			bubble_container.add_child(bubble)
	if delta_bubbles < 0:
		for i in range(abs(delta_bubbles)):
			# delete
			bubble_container.get_child(current_bubble_count - i - 1).drain()
	$Control/HBoxContainer.offset_right += delta_bubbles * 223
		

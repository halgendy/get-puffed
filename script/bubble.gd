extends Control

var started_drain := false
var drained := false

func drain():
	if started_drain: return
	started_drain = true
	drained = true
	$Bubble.play("drain")


func _on_bubble_animation_finished():
	$Bubble.modulate = Color.TRANSPARENT

extends Node

func play_audio(stream: AudioStream):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.finished.connect(finished_sfx.bind(instance))
	add_child(instance)
	instance.play()
	
func finished_sfx(instance: AudioStreamPlayer):
	instance.queue_free()

extends Node

var music: AudioStreamPlayer

func play_audio(stream: AudioStream):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.finished.connect(finished_sfx.bind(instance))
	add_child(instance)
	instance.play()

func play_music(stream: AudioStream):
	music = AudioStreamPlayer.new()
	music.name = "Music"
	music.stream = stream
	music.finished.connect(finished_music.bind(music))
	add_child(music)
	music.play()
	
func finished_sfx(instance: AudioStreamPlayer):
	instance.queue_free()

func finished_music(instance: AudioStreamPlayer):
	instance.play()

func stop_music():
	music.stop()

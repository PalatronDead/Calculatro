extends Node

var num_players = 3
var bus = "Master"

var availablePlayers: Array[AudioStreamPlayer] = []

func _ready():
	for i in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus
		
		availablePlayers.append(player)

func _on_stream_finished(stream_player):
	availablePlayers.append(stream_player)

func play_sfx(stream: AudioStream, pitch_variance: float = 0.1):
	if stream == null:
		return;
	if availablePlayers.size() > 0:
		var player = availablePlayers.pop_back()
		
		player.stream = stream
		
		if pitch_variance > 0:
			player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
		else:
			player.pitch_scale = 1.0
		
		player.play()
	else:
		print("Too many players playing, SADGE")

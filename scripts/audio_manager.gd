extends Node
class_name AshenrootAudioManager

const DEFAULT_SOUNDS := {
	"hit": {"freq": 180.0, "duration": 0.08, "volume": -10.0},
	"pickup": {"freq": 820.0, "duration": 0.10, "volume": -12.0},
	"hurt": {"freq": 110.0, "duration": 0.16, "volume": -9.0},
	"mine": {"freq": 260.0, "duration": 0.06, "volume": -14.0},
	"shoot": {"freq": 520.0, "duration": 0.09, "volume": -12.0},
	"boss": {"freq": 74.0, "duration": 0.45, "volume": -8.0},
	"forest_event": {"freq": 640.0, "duration": 0.22, "volume": -14.0},
	"cave_event": {"freq": 210.0, "duration": 0.24, "volume": -13.0},
	"mushroom_event": {"freq": 420.0, "duration": 0.28, "volume": -13.0},
	"ash_event": {"freq": 96.0, "duration": 0.36, "volume": -11.0},
	"water_event": {"freq": 330.0, "duration": 0.30, "volume": -14.0},
	"lava_event": {"freq": 130.0, "duration": 0.32, "volume": -11.0},
	"glass_event": {"freq": 920.0, "duration": 0.24, "volume": -15.0}
}

var sound_players: Dictionary = {}


func setup() -> void:
	for child in get_children():
		child.queue_free()
	sound_players.clear()
	for sound_name in DEFAULT_SOUNDS:
		var sound_data: Dictionary = DEFAULT_SOUNDS[sound_name]
		var player := AudioStreamPlayer.new()
		player.name = "Sound_%s" % sound_name
		player.stream = _make_tone(float(sound_data["freq"]), float(sound_data["duration"]))
		player.volume_db = float(sound_data["volume"])
		add_child(player)
		sound_players[str(sound_name)] = player


func play(sound_name: String) -> void:
	if not sound_players.has(sound_name):
		return
	var player: AudioStreamPlayer = sound_players[sound_name]
	player.stop()
	player.play()


func _make_tone(frequency: float, duration: float) -> AudioStreamWAV:
	var mix_rate := 22050
	var sample_count := int(float(mix_rate) * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / float(mix_rate)
		var fade := 1.0 - float(i) / float(maxi(1, sample_count))
		var wave := sin(t * frequency * TAU) * fade
		var sample := int(clampf(wave, -1.0, 1.0) * 18000.0)
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream

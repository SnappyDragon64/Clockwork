extends Node

const ANIMATION_DURATION = 0.10
const MUFFLED_CUTOFF_HZ = 800.0
const NORMAL_CUTOFF_HZ = 20500.0

const NORMAL_VOLUME_DB = 0.0
const LOWERED_VOLUME_DB = -16.0

var _master_bus_index: int
var _low_pass_filter: AudioEffectLowPassFilter

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	_master_bus_index = AudioServer.get_bus_index("Master")
	_low_pass_filter = AudioServer.get_bus_effect(_master_bus_index, 0)
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _on_bullet_time_started(_data: Dictionary) -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_low_pass_filter, "cutoff_hz", MUFFLED_CUTOFF_HZ, ANIMATION_DURATION)
	tween.tween_property(audio_player, "volume_db", LOWERED_VOLUME_DB, ANIMATION_DURATION)


func _on_bullet_time_ended(_data: Dictionary) -> void:
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_low_pass_filter, "cutoff_hz", NORMAL_CUTOFF_HZ, ANIMATION_DURATION)
	tween.tween_property(audio_player, "volume_db", NORMAL_VOLUME_DB, ANIMATION_DURATION)

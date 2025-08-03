extends AnimationTree

@export var _is_player: bool = false

func _ready() -> void:
	active = true
	if not _is_player:
		get("parameters/playback").travel("Idle")
	else:
		get("parameters/playback").travel("Default")
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _on_bullet_time_started(data: Dictionary) -> void:
	if _is_player:
		get("parameters/playback").travel("BulletTime")
	else:
		active = false


func _on_bullet_time_ended(data: Dictionary) -> void:
	if _is_player:
		get("parameters/playback").travel("Default")
	else:
		active = true

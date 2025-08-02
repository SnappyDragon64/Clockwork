extends AnimationTree

func _ready() -> void:
	active = true
	get("parameters/playback").travel("Idle")
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _on_bullet_time_started(data: Dictionary) -> void:
	active = false


func _on_bullet_time_ended(data: Dictionary) -> void:
	active = true

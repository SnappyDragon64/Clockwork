extends Node

func _ready() -> void:
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)

func _on_bullet_time_started(data: Dictionary) -> void:
	get_owner().set_process_mode(Node.PROCESS_MODE_DISABLED)

func _on_bullet_time_ended(data: Dictionary) -> void:
	get_owner().set_process_mode(Node.PROCESS_MODE_INHERIT)

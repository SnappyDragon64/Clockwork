class_name HealthTower extends BaseTower

@export var health_gain: float = 1

var _has_been_activated: bool = false

func _on_activated() -> void:
	super._on_activated()
	if current_state == State.RAISED and not _has_been_activated:
		_grant_health()

func _grant_health():
	EventBus.publish(Events.PLAYER_GAIN_HEALTH, {"health_gain": health_gain})

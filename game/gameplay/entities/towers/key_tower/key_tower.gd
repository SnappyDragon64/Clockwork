class_name KeyTower extends BaseTower

signal key_activated
signal key_deactivated

var _has_been_activated : bool = false

func _on_activated():
	super._on_activated()
	
	if current_state == State.RAISED and not _has_been_activated:
		_has_been_activated = true
		key_activated.emit()
	
	elif current_state == State.REST and _has_been_activated:
		_has_been_activated = false
		key_deactivated.emit()

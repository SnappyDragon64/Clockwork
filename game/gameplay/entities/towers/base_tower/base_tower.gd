class_name BaseTower extends AnimatableBody3D

enum State {
	REST,
	RAISED
}

@export var current_state: State = State.REST
@export var height: float = 3
@export var time: float = 1

@onready var loopable_component: LoopableComponent = $LoopableComponent

var _active_tween: Tween
var _rest_position
var _raised_position
var _transition_lock_flag: bool = false


func _ready():
	loopable_component.activated.connect(_on_activated)
	
	if current_state == State.REST:
		_rest_position = position
		_raised_position = position + Vector3(0, height, 0)
	else:
		_rest_position = position - Vector3(0, height, 0)
		_raised_position = position
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _on_activated():
	if not _transition_lock_flag:
		_transition_lock_flag = true
		if current_state == State.REST:
			current_state = State.RAISED
		else:
			current_state = State.REST
		_on_state_change()


func _on_state_change():
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE)
	_active_tween.set_ease(Tween.EASE_IN_OUT)
	_active_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	if current_state == State.REST:
		_active_tween.tween_property(self, "position", _rest_position, time)
	else:
		_active_tween.tween_property(self, "position", _raised_position, time)
	
	_active_tween.finished.connect(free_transition_lock)


func free_transition_lock() -> void:
	_transition_lock_flag = false


func _on_bullet_time_started(data: Dictionary) -> void:
	if _active_tween:
		_active_tween.pause()


func _on_bullet_time_ended(data: Dictionary) -> void:
	if _active_tween:
		_active_tween.play()

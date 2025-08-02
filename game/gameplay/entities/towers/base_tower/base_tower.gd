class_name BaseTower extends AnimatableBody3D

enum State {
	REST,
	RAISED
}

@export var current_state: State = State.REST
@export var height: float = 3
@export var time: float = 1
@export var has_been_activated: bool = false

@onready var loopable_component: LoopableComponent = $LoopableComponent

var _active_tween: Tween
var _rest_position
var _raised_position


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
	
	_on_activated()


func _on_activated():
	if current_state == State.REST:
		current_state = State.RAISED
	else:
		current_state = State.REST
	_on_state_change()


func _on_state_change():
	print("state changing")
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_SINE)
	_active_tween.set_ease(Tween.EASE_IN_OUT)
	_active_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	if current_state == State.REST:
		_active_tween.tween_property(self, "position", _rest_position, time)
	else:
		_active_tween.tween_property(self, "position", _raised_position, time)


func _on_bullet_time_started(data: Dictionary) -> void:
	_active_tween.pause()


func _on_bullet_time_ended(data: Dictionary) -> void:
	_active_tween.play()

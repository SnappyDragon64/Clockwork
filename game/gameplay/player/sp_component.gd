class_name SPComponent extends Node


signal sp_changed(current_sp: float, max_sp: float)
signal ability_activated()
signal ability_deactivated()

@export_group("SP Stats")
@export var max_sp: float = 100.0
@export var sp_for_ability: float = 25.0
@export var ability_duration: float = 5.0

var current_sp: float = 0.0
var sp_after_ability: float = 0.0
var is_ability_active: bool = false
var _drain_timer: Timer


func _ready() -> void:
	_drain_timer = Timer.new()
	_drain_timer.name = "SPDrainTimer"
	_drain_timer.wait_time = 0.05
	_drain_timer.timeout.connect(_on_drain_timer_timeout)
	add_child(_drain_timer)
	sp_changed.emit(current_sp, max_sp)


func add_sp(amount: float) -> void:
	if is_ability_active or current_sp >= max_sp:
		return

	current_sp = min(current_sp + amount, max_sp)
	sp_changed.emit(current_sp, max_sp)
	print("SP:", current_sp)


func attempt_activate_ability() -> void:
	if current_sp >= sp_for_ability and not is_ability_active:
		is_ability_active = true
		sp_after_ability = current_sp - sp_for_ability
		_drain_timer.start()
		ability_activated.emit()


func _on_drain_timer_timeout() -> void:
	if not is_ability_active:
		_drain_timer.stop()
		return

	var drain_rate = sp_for_ability / ability_duration
	current_sp = max(0.0, current_sp - (drain_rate * _drain_timer.wait_time))
	sp_changed.emit(current_sp, max_sp)
	print("SP:", current_sp)
	
	if current_sp <= sp_after_ability:
		is_ability_active = false
		_drain_timer.stop()
		ability_deactivated.emit()

class_name HealthComponent extends Node


signal health_changed(current_health: float, max_health: float)
signal iframes_ended()
signal died()
signal damaged()

@export_group("Health Stats")
@export var max_health: float = 10.0
@export var is_player: bool = false

var current_health: float
var invincible: bool = false
var _iframe_timer


func _ready() -> void:
	current_health = max_health

	if is_player:
		_iframe_timer = Timer.new()
		_iframe_timer.one_shot = true
		_iframe_timer.wait_time = 1.5
		_iframe_timer.timeout.connect(_on_iframe_finished)
		add_child(_iframe_timer)


func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
	
	if is_player and invincible:
		return
	
	damaged.emit()
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)

	if is_player and not invincible:
		initiate_iframes()
		
	
	if current_health == 0:
		died.emit()


func add_health(amount: float) -> void:
	if current_health >= max_health:
		return
	
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)


func initiate_iframes():
	_iframe_timer.start()
	invincible = true


func _on_iframe_finished():
	invincible = false
	iframes_ended.emit()

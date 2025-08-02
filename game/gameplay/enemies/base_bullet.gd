class_name BaseBullet extends Area3D

var speed: float
var damage: float
var lifetime: float
var shooter: Node

var lifetime_timer: Timer
@onready var sprite: Sprite3D = $Sprite3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var is_dying: bool = false
var _speed_multiplier: float = 1.0
var _is_in_bullet_time: bool = false


func _ready() -> void: 
	lifetime_timer = Timer.new()
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	add_child(lifetime_timer)

	if _is_in_bullet_time:
		lifetime_timer.paused = true

	lifetime_timer.start()
	
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)

	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _physics_process(delta: float) -> void:
	if is_dying:
		return
		
	position += -transform.basis.z * speed * _speed_multiplier * delta


func apply_bullet_time_effects(multiplier: float, pause_lifetime: bool = false) -> void:
	if is_dying:
		return

	_speed_multiplier = multiplier
	_is_in_bullet_time = pause_lifetime

	if is_instance_valid(lifetime_timer):
		lifetime_timer.paused = _is_in_bullet_time


func _on_hit(node: Node3D) -> void:
	if is_dying:
		return
	
	_start_death_sequence()
	
	if node is Player:
		node.health_component.take_damage(damage)


func _on_lifetime_timeout() -> void:
	if is_dying:
		return
	
	_start_death_sequence()


func _start_death_sequence() -> void:
	is_dying = true
	queue_free()


func _on_bullet_time_started(data: Dictionary) -> void:
	var multiplier: float = data.get("speed_multiplier", 1.0)
	apply_bullet_time_effects(multiplier, true)


func _on_bullet_time_ended(_data: Dictionary) -> void:
	apply_bullet_time_effects(1.0, false)

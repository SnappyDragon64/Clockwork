class_name BaseBullet extends Area3D

var speed: float
var damage: float
var lifetime: float
var shooter: Node

var lifetime_timer: Timer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var is_dying: bool = false
var _speed_multiplier: float = 1.0


func _ready() -> void: 
	lifetime_timer = Timer.new()
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	add_child(lifetime_timer)

	lifetime_timer.start()
	
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _physics_process(delta: float) -> void:
	if is_dying:
		return
		
	position += -transform.basis.z * speed * _speed_multiplier * delta


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
	_speed_multiplier = data.speed_multiplier
	lifetime_timer.paused = true


func _on_bullet_time_ended(data: Dictionary) -> void:
	_speed_multiplier = 1.0
	lifetime_timer.paused = false

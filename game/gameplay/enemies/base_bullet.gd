class_name BaseBullet extends Area3D

var speed: float
var damage: float
var lifetime: float
var shooter: Node

var lifetime_timer: Timer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var is_dying: bool = false


func _ready() -> void: 
	lifetime_timer = Timer.new()
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	add_child(lifetime_timer)

	lifetime_timer.start()
	
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)


func _physics_process(delta: float) -> void:
	if is_dying:
		return
		
	position += -transform.basis.z * speed * delta


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

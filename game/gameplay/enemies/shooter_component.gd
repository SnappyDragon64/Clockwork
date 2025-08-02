class_name ShooterComponent extends Node3D


@export var pattern: ShooterPatternEntry
@export var auto_fire: bool = true
@export var alt_offset: bool = false

var _round_counter: int = 0
var _bullet_scene: PackedScene
var _can_shoot: bool = true
var _is_dead: bool = false

var _cooldown_timer: Timer
var _fire_rate_timer: Timer
var _shoot_period: Timer
var offset_flag: int = 1

var _speed_multiplier: float = 1.0
var _is_bullet_time: bool = false


func _ready() -> void:
	if not is_instance_valid(pattern):
		push_warning("ShooterComponent on '%s' has no pattern assigned." % owner.name)
		set_process(false)
		return
		
	_bullet_scene = load(pattern.path)
	
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.wait_time = pattern.cooldown
	_cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(_cooldown_timer)
	
	
	_fire_rate_timer = Timer.new()
	_fire_rate_timer.one_shot = true
	_fire_rate_timer.wait_time = pattern.rate
	_fire_rate_timer.timeout.connect(_fire_volley)
	add_child(_fire_rate_timer)
	
	if auto_fire:
		_cooldown_timer.start()
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func attempt_shoot() -> void:
	if _is_bullet_time:
		return
	
	if _can_shoot and not _is_dead:
		_shoot()


func _shoot() -> void:
	if _is_bullet_time:
		return
	
	_can_shoot = false
	_round_counter = 0
	_fire_volley()


func _fire_volley() -> void:
	if _is_dead or _round_counter >= pattern.rounds or _is_bullet_time:
		_fire_rate_timer.stop()
		if not _is_bullet_time:
			_cooldown_timer.start()
		return

	var angle_step = 0.0
	if pattern.bullets > 1:
		angle_step = deg_to_rad(pattern.spread) / (pattern.bullets)
	
	var base_angle = deg_to_rad(pattern.angle_offset) - (deg_to_rad(pattern.spread) / 2.0)
	
	if alt_offset and offset_flag == -1:
		base_angle = deg_to_rad(0) - (deg_to_rad(pattern.spread) / 2.0)
	
	offset_flag *= -1
	
	for i in range(pattern.bullets):
		var current_angle = base_angle + (i * angle_step)
		var bullet: BaseBullet = _bullet_scene.instantiate()
		
		var spawn_transform = global_transform
		var fire_direction = Vector3.BACK.rotated(Vector3.UP, current_angle)
		
		spawn_transform.origin -= spawn_transform.basis * (fire_direction * pattern.radius)
		spawn_transform.basis = spawn_transform.basis.rotated(Vector3.UP, current_angle)
		
		bullet.speed = pattern.speed
		bullet.damage = pattern.damage
		bullet.lifetime = pattern.lifetime
		bullet.shooter = owner
		bullet.global_transform = spawn_transform
		
		EventBus.publish(Events.SPAWN_ENTITY, { "entity": bullet })

	_round_counter += 1
	
	if _round_counter < pattern.rounds:
		_fire_rate_timer.start()
	else:
		_cooldown_timer.start()


func _on_cooldown_finished() -> void:
	_can_shoot = true

	if auto_fire and not _is_dead:
		attempt_shoot()

func try_shoot():
	_shoot_period = $ShootPeriod
	auto_fire = true
	_shoot_period.start()
	_cooldown_timer.start()


func _on_shoot_period_timeout() -> void:
	auto_fire = false


func _on_bullet_time_started(data: Dictionary) -> void:
	_speed_multiplier = data.speed_multiplier

	_is_bullet_time = true
	_cooldown_timer.paused = true
	_fire_rate_timer.paused = true


func _on_bullet_time_ended(data: Dictionary) -> void:
	_speed_multiplier = 1.0

	_is_bullet_time = false
	_cooldown_timer.paused = false
	_fire_rate_timer.paused = false

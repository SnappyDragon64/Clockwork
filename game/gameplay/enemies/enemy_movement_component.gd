class_name EnemyMovementComponent extends Node3D

enum MovementType {
	STATIONARY,
	FOLLOW_PLAYER,
	FOLLOW_PATH
}

@export var look_at_player: bool = false
@export var spin: bool = false
@export var movement_type: MovementType
@export var speed: float = 4.0

@export_group("Follow Player Settings")
@export var stopping_distance: float = 2.0

@export_group("Follow Path Settings")
@export var path_node: Path3D

@onready var enemy_body: CharacterBody3D = get_owner() as CharacterBody3D
@onready var player_position: Vector3

var _has_received_position: bool = false
var path_progress: float = 0.0
var _speed_multiplier: float = 1
var _is_bullet_time: bool = false


func _ready() -> void:
	if movement_type == MovementType.FOLLOW_PLAYER or look_at_player == true:
		EventBus.subscribe(Events.PLAYER_MOVED, _update_direction)

	if movement_type == MovementType.FOLLOW_PATH and not path_node:
		movement_type = MovementType.STATIONARY
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _physics_process(delta: float) -> void:
	match movement_type:
		MovementType.STATIONARY:
			_move_stationary(delta)
		
		MovementType.FOLLOW_PLAYER:
			_move_follow_player()
			
		MovementType.FOLLOW_PATH:
			_move_follow_path(delta)
	
	if not enemy_body.is_on_floor():
		enemy_body.velocity.y -= 3 * 9.8 * delta

	enemy_body.move_and_slide()


func _update_direction(data: Dictionary):
	player_position = data.player_position
	_has_received_position = true


func _move_stationary(delta) -> void:
	enemy_body.velocity = Vector3.ZERO
	if not _is_bullet_time:
		if look_at_player and _has_received_position:
			enemy_body.look_at(player_position, Vector3.UP)
		if spin:
			enemy_body.rotate(Vector3(0, 1, 0), 3*delta/4)


func _move_follow_player():
	if not _has_received_position:
		return

	var target_on_plane = player_position
	target_on_plane.y = enemy_body.global_position.y
	
	if not _is_bullet_time:
		enemy_body.look_at(target_on_plane, Vector3.UP)

	var distance = enemy_body.global_position.distance_to(target_on_plane)
	var current_speed = speed * _speed_multiplier
	
	if distance > stopping_distance:
		var direction = (target_on_plane - enemy_body.global_position).normalized()
		enemy_body.velocity = direction * current_speed
	else:
		enemy_body.velocity = Vector3.ZERO


func _move_follow_path(delta: float):
	if not path_node:
		return

	var current_path_speed = speed * _speed_multiplier
	path_progress += current_path_speed * delta
	var next_position = path_node.curve.sample_baked(path_progress)
	
	if not _is_bullet_time:
		if not look_at_player:
			enemy_body.look_at(next_position, Vector3.UP)
		elif _has_received_position:
			enemy_body.look_at(player_position, Vector3.UP)
	
	var direction = (next_position - enemy_body.global_position).normalized()
	enemy_body.velocity = direction * current_path_speed

	var path_length = path_node.curve.get_baked_length()
	if path_progress >= path_length:
		path_progress = fmod(path_progress, path_length)


func _on_bullet_time_started(data: Dictionary) -> void:
	_speed_multiplier = data.speed_multiplier
	_is_bullet_time = true


func _on_bullet_time_ended(data: Dictionary) -> void:
	_speed_multiplier = 1.0
	_is_bullet_time = false

extends Node3D

@export var look_at_player: bool = false
@export var spin: bool = false
@export var speed: float = 4.0
@export var running_distance: float = 5.0

@onready var enemy_body: CharacterBody3D = get_owner() as CharacterBody3D
@onready var player_position: Vector3

var _has_received_position: bool = false
var path_progress: float = 0.0
var _speed_multiplier: float = 1
var _is_bullet_time: bool = false


func _ready() -> void:
	EventBus.subscribe(Events.PLAYER_MOVED, _update_direction)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _physics_process(delta: float) -> void:

	_move_follow_player()
	enemy_body.move_and_slide()


func _on_bullet_time_started(data: Dictionary) -> void:
	_speed_multiplier = data.speed_multiplier
	_is_bullet_time = true


func _on_bullet_time_ended(data: Dictionary) -> void:
	_speed_multiplier = 1.0
	_is_bullet_time = false






func _move_follow_player():
	if not _has_received_position:
		return

	var target_on_plane = player_position
	target_on_plane.y = enemy_body.global_position.y
	
	if not _is_bullet_time:
		enemy_body.look_at(target_on_plane, Vector3.UP)

	var distance = enemy_body.global_position.distance_to(target_on_plane)
	var current_speed = speed * _speed_multiplier
	
	if distance < running_distance:
		var direction = (enemy_body.global_position - target_on_plane).normalized()
		enemy_body.velocity = direction * current_speed
	else:
		enemy_body.velocity = Vector3.ZERO


func _update_direction(data: Dictionary):
	player_position = data.player_position
	_has_received_position = true

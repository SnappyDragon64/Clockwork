class_name CameraAnchor extends Node3D


var offset: Vector3 = Vector3(0, 8, 10)
var player_position: Vector3
var min_x: float = -12.0
var max_x: float = 12.0
var is_shaking: bool = false

@export var shake_offset: Vector3 = Vector3(0.1, 0.1, 0)
@export var jerk_speed: float = 0.03
@export var jerk_count: int = 2

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	EventBus.subscribe(Events.PLAYER_MOVED, _on_player_moved)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 16.0
	camera.far = 100.0
	camera.rotation.x = -PI/4
	
	


func _process(delta: float) -> void:
	global_position = _calculate_target_position()

func _on_player_moved(data: Dictionary) -> void:
	player_position = data.player_position

func _calculate_target_position() -> Vector3:
	if player_position == null:
		return offset

	var target_position = player_position + offset
	#target_position.x = clamp(target_position.x, min_x, max_x)
	#target_position.y = offset.y
	#target_position.z = offset.z
	return target_position

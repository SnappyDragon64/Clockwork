class_name MeshAnchor extends Node3D

@export var max_tilt_angle: float = 15.0
@export var tilt_speed: float = 7.0 
@export var rotation_speed: float = 7.0

@onready var mesh: Node3D = $Mesh

var direction: Vector3
var _is_bullet_time: bool = false
var _speed_multiplier: float = 1.0



func _ready() -> void:
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)

func _process(delta: float) -> void:
	if not _is_bullet_time:
		if direction != Vector3.ZERO:
			var target_angle_y = atan2(direction.x, direction.z) - PI/2
			
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle_y, rotation_speed * _speed_multiplier * delta)

			var target_tilt_rads_x = deg_to_rad(direction.z * max_tilt_angle)
			rotation.x = lerp(rotation.x, target_tilt_rads_x, tilt_speed * _speed_multiplier * delta)
	#
			var target_tilt_rads_z = deg_to_rad(-direction.x * max_tilt_angle)
			rotation.z = lerp(rotation.z, target_tilt_rads_z, tilt_speed * _speed_multiplier * delta)
		else:
			rotation.x = lerp(rotation.x, 0.0, tilt_speed * _speed_multiplier * delta)
			rotation.z = lerp(rotation.z, 0.0, tilt_speed * _speed_multiplier * delta)


func _on_move_input_vector_changed(vector: Vector2) -> void:
	direction = Vector3(vector.x, 0, vector.y).normalized()


func _on_bullet_time_started(data: Dictionary) -> void:
	if not Player:
		_speed_multiplier = data.speed_multiplier
		_is_bullet_time = true


func _on_bullet_time_ended(data: Dictionary) -> void:
	if not Player:
		_speed_multiplier = 1.0
		_is_bullet_time = false

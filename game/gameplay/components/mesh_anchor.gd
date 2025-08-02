class_name MeshAnchor extends Node3D

@export var max_tilt_angle: float = 15.0
@export var tilt_speed: float = 7.0 
@export var rotation_speed: float = 7.0

@onready var mesh: Node3D = $Mesh

var direction: Vector3


func _process(delta: float) -> void:
	if direction != Vector3.ZERO:
		var target_angle_y = atan2(direction.x, direction.z) - PI/2
		
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_angle_y, rotation_speed * delta)

		var target_tilt_rads_x = deg_to_rad(direction.z * max_tilt_angle)
		rotation.x = lerp(rotation.x, target_tilt_rads_x, tilt_speed * delta)
#
		var target_tilt_rads_z = deg_to_rad(-direction.x * max_tilt_angle)
		rotation.z = lerp(rotation.z, target_tilt_rads_z, tilt_speed * delta)
	else:
		rotation.x = lerp(rotation.x, 0.0, tilt_speed * delta)
		rotation.z = lerp(rotation.z, 0.0, tilt_speed * delta)


func _on_move_input_vector_changed(vector: Vector2) -> void:
	direction = Vector3(vector.x, 0, vector.y).normalized()

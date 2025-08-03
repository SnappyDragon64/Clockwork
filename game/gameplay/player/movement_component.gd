class_name MovementComponent extends Node


@onready var player: Player = get_owner() as Player

var direction: Vector3

func process_physics(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y -= 3 * 9.8 * delta

	player.velocity.x = direction.x * player.speed
	player.velocity.z = direction.z * player.speed

	player.move_and_slide()
	EventBus.publish(Events.PLAYER_MOVED, { "player_position": player.global_position })


func _on_move_input_vector_changed(vector: Vector2) -> void:
	direction = Vector3(vector.x, 0, vector.y).normalized()

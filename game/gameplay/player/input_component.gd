class_name InputComponent extends Node


signal move_input_vector_changed(vector: Vector2)

signal loop_started()
signal loop_stopped()
signal sp_ability_initiate()

@onready var player: Player = get_owner() as Player


func _input(event: InputEvent) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_input_vector_changed.emit(input_vector)

	if Input.is_action_just_pressed("loop"):
		loop_started.emit()
	elif Input.is_action_just_released("loop"):
		loop_stopped.emit()
	if Input.is_action_just_pressed("sp_ability"):
		sp_ability_initiate.emit()

class_name Player extends CharacterBody3D


@export var speed: float = 4.0

@onready var input_component: InputComponent = $InputComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var loop_component: LoopComponent = $LoopComponent


func _ready() -> void:
	input_component.move_input_vector_changed.connect(movement_component._on_move_input_vector_changed)
	input_component.loop_started.connect(loop_component._on_loop_started)
	input_component.loop_stopped.connect(loop_component._on_loop_stopped)


func _physics_process(delta: float) -> void:
	movement_component.process_physics(delta)

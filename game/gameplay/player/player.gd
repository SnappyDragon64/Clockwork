class_name Player extends CharacterBody3D


@export var speed: float = 4.0

@onready var input_component: InputComponent = $InputComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var loop_component: LoopComponent = $LoopComponent
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var mesh_anchor: MeshAnchor = $MeshAnchor
@onready var health_component: HealthComponent = $HealthComponent

var dead: bool = false


func _ready() -> void:
	input_component.move_input_vector_changed.connect(movement_component._on_move_input_vector_changed)
	input_component.move_input_vector_changed.connect(mesh_anchor._on_move_input_vector_changed)
	input_component.loop_started.connect(loop_component._on_loop_started)
	input_component.loop_stopped.connect(loop_component._on_loop_stopped)
	
	health_component.died.connect(_on_death)
	health_component.iframes_ended.connect(_on_iframes_ended)
	health_component.damaged.connect(_on_damaged)
	health_component.health_changed.connect(_on_health_changed)


func _physics_process(delta: float) -> void:
	movement_component.process_physics(delta)


func _on_health_changed(current_health: float, max_health: float) -> void:
	EventBus.publish(Events.PLAYER_HEALTH_CHANGED, {"current_health": current_health, "max_health": max_health})


func _on_sp_changed(current_sp: float, max_sp: float) -> void:
	EventBus.publish(Events.PLAYER_SP_CHANGED, {"current_sp": current_sp, "max_sp": max_sp})



func _on_damaged() -> void:
	pass


func _on_iframes_ended() -> void:
	pass


func _on_death() -> void:
	if not dead:
		$CollisionShape3D.set_disabled(true)
		#$GrazeComponent/CollisionShape3D.set_disabled(true)
		set_process(false)
		set_physics_process(false)
		set_visible(false)
		dead = true
		await get_tree().create_timer(1.0).timeout
		EventBus.publish(Events.PLAYER_DIED)

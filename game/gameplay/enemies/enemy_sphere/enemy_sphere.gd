extends CharacterBody3D

@onready var health_component: HealthComponent = $HealthComponent
@onready var loopable_component: LoopableComponent = $LoopableComponent
@onready var mesh_anchor: MeshAnchor = $MeshAnchor

var is_dead: bool = false


func _ready() -> void:
	health_component.died.connect(_on_death)
	health_component.damaged.connect(_on_damaged)
	
	loopable_component.activated.connect(_on_activated)
	
	set_collision_layer_value(8, true)


func _on_death() -> void:
	if is_dead:
		return
	is_dead = true
	_emit_particles()
	$CollisionShape3D.disabled = true


func _emit_particles() -> void:
	pass
	queue_free()


func _on_damaged() -> void:
	pass
	#mesh_anchor.flash_red()


func _on_activated() -> void:
	health_component.take_damage(1.0)

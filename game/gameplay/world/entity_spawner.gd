extends Node3D


func _ready():
	EventBus.subscribe(Events.SPAWN_ENTITY, _on_spawn_entity)


func _on_spawn_entity(data: Dictionary) -> void:
	var entity: Node = data.entity
	add_child.call_deferred(entity)

extends Area3D

@export var scene_set_to_load: SceneSetEntry



func _on_body_entered(body: Node3D) -> void:
	SceneSetManager.change_set(scene_set_to_load)

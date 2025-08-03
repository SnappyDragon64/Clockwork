class_name TextArea extends Area3D

@export var text = ""
var hud: HUD


func _on_ready() -> void:
	collision_layer = 0
	collision_mask = 0
	
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)
	
	SceneSetManager.scene_set_initialized.connect(_on_scene_set_initialized)


func _on_scene_set_initialized(context: SceneSetContext) -> void:
	hud = context.get_scene(Scenes.UI_HUD)


func _on_body_entered():
	hud.set_text(text)

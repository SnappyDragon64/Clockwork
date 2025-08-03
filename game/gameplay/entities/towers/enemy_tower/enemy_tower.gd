class_name EnemyTower extends BaseTower

@export var enemy_paths: Array[NodePath]


func _on_activated() -> void:
	super._on_activated()
	if current_state == State.RAISED:
		super._on_state_change()
		_deactivate_enemies()


func _deactivate_enemies():
	if enemy_paths.is_empty():
		return

	for path in enemy_paths:
		var enemy_node = get_node(path)
		if is_instance_valid(enemy_node):
			enemy_node.deactivate() 
	enemy_paths.clear()

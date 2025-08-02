class_name Door extends Node3D

@export var key_towers: Array[KeyTower]

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _keys_required: int
var _keys_activated_count: int = 0

func _ready():
	if key_towers.is_empty():
		return
	
	_keys_required = key_towers.size()
	
	for tower in key_towers:
		tower.key_activated.connect(_on_key_tower_activated)


func _on_key_tower_activated():
	_keys_activated_count += 1

	if _keys_activated_count >= _keys_required:
		_open_door()


func _open_door():
	animation_player.play("open")
	
	

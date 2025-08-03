class_name LoopableComponent extends Area3D

signal activated

var is_bullet_time_active := false
var deferred_signal_flag := false


var loop_particles_scene: PackedScene = preload(Scenes.PARTICLES_LOOP_PARTICLES.path)
var base_pos


func _ready() -> void:
	base_pos = global_position
	collision_layer = 0
	collision_mask = 0
	monitorable = true
	set_collision_mask_value(6, true)
	monitoring = true
	
	area_entered.connect(_on_area_entered)
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func looped() -> void:
	activated.emit()


func _on_area_entered(area: Area3D) -> void:
	if is_bullet_time_active:
		deferred_signal_flag = true
	else:
		looped()


func _on_bullet_time_started(_data: Dictionary) -> void:
	is_bullet_time_active = true


func _on_bullet_time_ended(_data: Dictionary) -> void:
	is_bullet_time_active = false
	
	if deferred_signal_flag:
		deferred_signal_flag = false
		looped()

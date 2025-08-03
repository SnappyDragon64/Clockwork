extends Node3D


func _ready() -> void:
	$GPUParticles3D.emitting = true
	$GPUParticles3D.finished.connect(_on_finish)
	
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_STARTED, _on_bullet_time_started)
	EventBus.subscribe(Events.PLAYER_BULLET_TIME_ENDED, _on_bullet_time_ended)


func _on_finish() -> void:
	queue_free()


func _on_bullet_time_started():
	$GPUParticles3D.speed_scale = 0.0


func _on_bullet_time_ended():
	$GPUParticles3D.speed_scale = 0.0

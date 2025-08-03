extends Control


const SP_BAR_ANIMATION_DURATION: float = 0.2

var _active_health_tween: Tween
var _active_sp_tween: Tween


func _ready() -> void:
	EventBus.subscribe(Events.PLAYER_HEALTH_CHANGED, _on_player_health_changed)
	EventBus.subscribe(Events.PLAYER_SP_CHANGED, _on_player_sp_changed)
	
	
func _on_player_health_changed(data: Dictionary) -> void:
	if _active_health_tween and _active_health_tween.is_valid():
		_active_health_tween.kill()

	var current_health = data.current_health
	var max_health = data.max_health
	
	var target_value = (current_health / max_health) * 100.0
	
	_active_health_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_health_tween.tween_property(%HealthBar, "value", target_value, SP_BAR_ANIMATION_DURATION)


func _on_player_sp_changed(data: Dictionary) -> void:
	if _active_sp_tween and _active_sp_tween.is_valid():
		_active_sp_tween.kill()

	var current_sp = data.current_sp
	var max_sp = data.max_sp
	
	var target_value = (current_sp / max_sp) * 100.0
	
	_active_sp_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_sp_tween.tween_property(%SPBar, "value", target_value, SP_BAR_ANIMATION_DURATION)

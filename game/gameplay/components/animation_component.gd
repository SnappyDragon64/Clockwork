extends AnimationTree

func _ready() -> void:
	active = true
	get("parameters/playback").travel("Idle")

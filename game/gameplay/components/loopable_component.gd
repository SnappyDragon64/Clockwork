class_name LoopableComponent extends Area3D

signal activated

func looped() -> void:
	activated.emit()

extends CharacterBody3D


@onready var shooter_component: ShooterComponent = $ShooterComponent


func deactivate() -> void:
	shooter_component.auto_fire = false

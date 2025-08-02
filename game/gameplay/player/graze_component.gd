class_name GrazeComponent extends Area3D


@onready var flash_duration: float = 0.3
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Sprite3D

signal grazed()

var flash_tween: Tween

func _ready() -> void:
	sprite.modulate.a = 0.0 
	sprite.visible = false


func _on_area_entered(_area: Area3D) -> void:
	grazed.emit()
	flash_graze_effect()


func flash_graze_effect() -> void:
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()

	flash_tween = create_tween()
	sprite.visible = true
	sprite.modulate.a = 1.0

	flash_tween.tween_property(sprite, "modulate:a", 0.0, flash_duration)
	flash_tween.tween_callback(func(): sprite.visible = false)

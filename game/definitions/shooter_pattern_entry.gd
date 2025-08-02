class_name ShooterPatternEntry
extends Resource

@export_group("Bullet")
@export_file("*.tscn") var path: String = "res://game/gameplay/enemies/base_bullet.tscn"
@export var speed: float = 5.0
@export var damage: float = 1.0
@export var lifetime: float = 1.0

@export_group("Timing")
@export var cooldown: float = 1.0
@export var rounds: int = 1
@export var rate: float = 0.1


@export_group("Shape")
@export var bullets: int = 1
@export var spread: float = 0.0
@export var radius: float = 1.0
@export var angle_offset: float = 0.0

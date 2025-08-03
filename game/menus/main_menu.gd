extends Control


@onready var play_button: CustomMenuButton = %PlayButton


func _ready():
	play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed():
	SceneSetManager.change_set(SceneSets.LEVEL0)

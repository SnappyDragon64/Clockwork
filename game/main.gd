extends Node


func _ready():
	SceneManager.load_scene(Scenes.WORLD_MUSIC_PLAYER)
	await SceneManager.load_scene(Scenes.TRANSITION_DEFAULT).completed
	TransitionManager.set_current_transition(Transitions.DEFAULT)
	SceneSetManager.change_set(SceneSets.MENU_MAIN_MENU)

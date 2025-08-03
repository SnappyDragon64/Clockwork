extends Node


func _ready():
	await SceneManager.load_scene(Scenes.TRANSITION_DEFAULT).completed
	TransitionManager.set_current_transition(Transitions.DEFAULT)
	SceneSetManager.change_set(SceneSets.LEVEL0)

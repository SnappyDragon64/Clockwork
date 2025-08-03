extends CharacterBody3D


@onready var shooter_component: ShooterComponent = $ShooterComponent
@onready var cube_1: MeshInstance3D = $turret_mesh/Cube
@onready var cube_2: MeshInstance3D = $turret_mesh/Cube_001

func deactivate() -> void:
	shooter_component.auto_fire = false
	
	
	var target_color = Color("494949")
	if cube_1 and cube_1.get_active_material(0):
		var material1 = cube_1.get_active_material(0).duplicate()
		material1.albedo_color = target_color
		cube_1.set_surface_override_material(0, material1)
	else:
		pass

	if cube_2 and cube_2.get_active_material(0):
		var material2 = cube_2.get_active_material(0).duplicate()
		material2.albedo_color = target_color
		cube_2.set_surface_override_material(0, material2)
	else:
		pass

@tool class_name Terrain extends StaticBody3D

@export var terrain_material: Material
@export var generate_now: bool = false:
	set(value):
		# This print will tell us if the checkbox is even working.
		print("Generate Now checkbox clicked!")
		if value:
			generate_visual_meshes()

#func _ready() -> void:
	#generate_visual_meshes()

func generate_visual_meshes() -> void:
	print("--- Starting Mesh Generation ---")
	
	if not terrain_material:
		printerr("ERROR: Terrain Material is not set. Stopping.")
		return

	var mesh_holder = find_child("MeshHolder")
	if mesh_holder:
		# When regenerating, it's safer to remove the old holder.
		mesh_holder.queue_free()

	# Create a new holder.
	mesh_holder = Node3D.new()
	mesh_holder.name = "MeshHolder"
	#mesh_holder.position.y = -0.5
	add_child(mesh_holder)
	
	mesh_holder.owner = get_tree().edited_scene_root
	print("1. MeshHolder created.")
	print("2. Searching for CollisionShape3D children...")

	for child in get_children():
		# This will print every child, helping us see what the loop is finding.
		print("   - Found child: ", child.name, " of type ", child.get_class())
		
		if child is CollisionShape3D:
			print("     -> It IS a CollisionShape3D.")
			var collision_shape = child as CollisionShape3D
			var shape_resource = collision_shape.shape
			
			# --- THIS IS THE MOST IMPORTANT TEST ---
			print("     -> Checking its 'shape' property. Resource is: ", shape_resource)
			
			if not shape_resource:
				print("     -> FAILURE: The 'shape' property is empty! Skipping this node.")
				continue # Skip to the next child

			var new_mesh_resource = _create_mesh_from_shape(shape_resource)
			if not new_mesh_resource:
				print("     -> FAILURE: _create_mesh_from_shape returned null. Unsupported shape? Skipping.")
				continue

			print("     -> SUCCESS: Created a mesh resource for it.")
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = new_mesh_resource
			mesh_instance.material_override = terrain_material
			mesh_instance.transform = collision_shape.transform
			mesh_instance.name = collision_shape.name + "_mesh"
			mesh_holder.add_child(mesh_instance)
			mesh_instance.owner = get_tree().edited_scene_root
			print("     -> Added '", mesh_instance.name, "' to MeshHolder.")

	print("--- Mesh Generation Finished ---")


func _create_mesh_from_shape(shape: Shape3D) -> Mesh:
	var new_mesh: Mesh
	
	# THE FIX: We now match on the string name of the class,
	# which is more reliable in the editor context.
	match shape.get_class():
		"BoxShape3D":
			var box_mesh = BoxMesh.new()
			box_mesh.size = shape.size
			new_mesh = box_mesh
			
		"SphereShape3D":
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = shape.radius
			sphere_mesh.height = shape.radius * 2.0
			new_mesh = sphere_mesh
			
		"CylinderShape3D":
			var cylinder_mesh = CylinderMesh.new()
			cylinder_mesh.radius = shape.radius
			cylinder_mesh.height = shape.height
			new_mesh = cylinder_mesh
			
		"CapsuleShape3D":
			var capsule_mesh = CapsuleMesh.new()
			capsule_mesh.radius = shape.radius
			capsule_mesh.height = shape.height
			new_mesh = capsule_mesh
		
	return new_mesh

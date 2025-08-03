@tool
extends MeshInstance3D
class_name PathLine3D

## The Path3D node to draw the mesh along.
@export var path_node: Path3D

## The material to apply to the line.
@export var line_material: Material

var _last_curve_positions_hash: int = 0

func _ready() -> void:
	_generate_mesh()

func _process(_delta: float) -> void:
	if not path_node or not path_node.curve:
		if self.mesh != null:
			self.mesh = null
		return

	var curve: Curve3D = path_node.curve
	var current_hash: int = 0
	if curve.get_point_count() > 0:
		for i in range(curve.get_point_count()):
			current_hash = hash_combine(current_hash, hash(curve.get_point_position(i)))
	
	if current_hash != _last_curve_positions_hash:
		_generate_mesh()
		_last_curve_positions_hash = current_hash

func _generate_mesh() -> void:
	if not is_inside_tree() or not path_node or not path_node.curve or not line_material:
		self.mesh = null
		return

	var curve: Curve3D = path_node.curve
	if curve.get_point_count() < 2:
		self.mesh = null
		return

	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var line_width: float = 0.25
	var half_width: float = line_width / 2.0
	
	# These will store the two end vertices of the PREVIOUS segment's quad.
	var prev_end_left: Vector3
	var prev_end_right: Vector3

	# Iterate through each segment defined by the curve's control points.
	for i in range(curve.get_point_count() - 1):
		var point_a_3d: Vector3 = curve.get_point_position(i)
		var point_b_3d: Vector3 = curve.get_point_position(i + 1)

		# Flatten the points to the XZ plane by setting Y to 0.
		var p1: Vector3 = Vector3(point_a_3d.x, 0.0, point_a_3d.z)
		var p2: Vector3 = Vector3(point_b_3d.x, 0.0, point_b_3d.z)

		if p1.is_equal_approx(p2):
			continue

		var tangent: Vector3 = (p2 - p1).normalized()
		var width_dir: Vector3 = tangent.cross(Vector3.UP).normalized()
		
		# Define the 4 corners of the quad for the CURRENT segment.
		var current_start_left: Vector3 = p1 - width_dir * half_width
		var current_start_right: Vector3 = p1 + width_dir * half_width
		var current_end_left: Vector3 = p2 - width_dir * half_width
		var current_end_right: Vector3 = p2 + width_dir * half_width

		# Set the normal for all vertices we are about to add. It is always UP.
		st.set_normal(Vector3.UP)

		# --- Draw the main quad for this segment ---
		# First triangle of the quad
		st.set_uv(Vector2(0, 0))
		st.add_vertex(current_start_left)
		st.set_uv(Vector2(0, 1))
		st.add_vertex(current_end_left)
		st.set_uv(Vector2(1, 1))
		st.add_vertex(current_end_right)
		# Second triangle of the quad
		st.set_uv(Vector2(0, 0))
		st.add_vertex(current_start_left)
		st.set_uv(Vector2(1, 1))
		st.add_vertex(current_end_right)
		st.set_uv(Vector2(1, 0))
		st.add_vertex(current_start_right)
		
		# --- Stitching Logic ---
		# If this is not the first segment (i > 0), then we have a previous segment to stitch to.
		if i > 0:
			# The joint point is p1 (the start point of the current segment).
			# We need to create a "fan" of two triangles to fill the gap.
			# The gap is between the previous segment's end (prev_end_left, prev_end_right)
			# and the current segment's start (current_start_left, current_start_right).
			
			# First fan triangle (fills the "left" side of the corner)
			st.add_vertex(p1)
			st.add_vertex(current_start_left)
			st.add_vertex(prev_end_left)
			
			# Second fan triangle (fills the "right" side of the corner)
			st.add_vertex(p1)
			st.add_vertex(prev_end_right)
			st.add_vertex(current_start_right)

		# At the end of the loop, store the end vertices of the CURRENT quad.
		# They will become the "previous" vertices in the next iteration.
		prev_end_left = current_end_left
		prev_end_right = current_end_right

	self.mesh = st.commit()
	
	var mat: Material = line_material.duplicate()
	if mat is StandardMaterial3D:
		var std_mat: StandardMaterial3D = mat
		std_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	elif mat is ORMMaterial3D:
		var orm_mat: ORMMaterial3D = mat
		orm_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	self.material_override = mat

func hash_combine(hash1: int, hash2: int) -> int:
	var h1: int = hash1
	var h2: int = hash2
	h1 = h1 ^ (h2 + 0x9e3779b9 + (h1 << 6) + (h1 >> 2))
	return h1

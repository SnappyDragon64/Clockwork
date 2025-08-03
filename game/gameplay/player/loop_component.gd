class_name LoopComponent extends Node


signal loop_completed(points: PackedVector2Array)

@export var min_points_for_loop: int = 4
@export var min_loop_detection_distance: float = 0.5
@export var point_collection_interval: float = 0.25
@export var self_intersection_tolerance: float = 0.01
@export var min_point_distance_for_collection: float = 0.25

@export var glow_color: Color = Color.CYAN

@onready var glow_effect_mesh: MeshInstance3D = $GlowEffectMesh


enum State { IDLE, DRAWING }
var current_state: State = State.IDLE

var points_buffer_3d: PackedVector3Array
var points_buffer_2d: PackedVector2Array
var sample_timer: Timer
var loop_detected_flag: bool = false
var detected_loops_buffer: Array


@onready var player: Player = get_owner() as Player

var loop_path_scene: PackedScene = preload(Scenes.PLAYER_LOOP_PATH.path)
var loop_area_scene: PackedScene = preload(Scenes.PLAYER_LOOP_AREA.path)

var loop_path: Path3D
var loop_area: Area3D


func _ready() -> void:
	sample_timer = Timer.new()
	sample_timer.wait_time = point_collection_interval
	sample_timer.one_shot = false
	sample_timer.timeout.connect(_on_sample_timer_timeout)
	add_child(sample_timer)
	
	var glow_material = StandardMaterial3D.new()

	glow_material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	glow_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	glow_material.emission_enabled = true
	glow_material.emission = glow_color
	
	glow_material.albedo_color = Color(glow_color, 0.0)

	glow_effect_mesh.material_override = glow_material
	
	SceneSetManager.scene_set_initialized.connect(_on_scene_set_initialized)


func _on_scene_set_initialized(_context: SceneSetContext):
	loop_path = loop_path_scene.instantiate()
	loop_area = loop_area_scene.instantiate()
	
	EventBus.publish(Events.SPAWN_ENTITY, { "entity": loop_path })
	EventBus.publish(Events.SPAWN_ENTITY, { "entity": loop_area })


func _process(delta: float) -> void:
	if current_state == State.DRAWING and not loop_detected_flag:
		_update_realtime_loop_detection()


func _on_loop_started() -> void:
	EventBus.publish(Events.PLAYER_LOOPING_STARTED)
	if current_state == State.IDLE:
		current_state = State.DRAWING
		_clear_path()
		loop_detected_flag = false

		var first_point_3d = _get_ground_position()
		if first_point_3d:
			points_buffer_3d.append(first_point_3d)
			points_buffer_2d.append(Vector2(first_point_3d.x, first_point_3d.z))
			if loop_path and loop_path.curve:
				loop_path.curve.add_point(first_point_3d)

		if sample_timer:
			sample_timer.start()


func _on_loop_stopped() -> void:
	EventBus.publish(Events.PLAYER_LOOPING_ENDED)
	if current_state == State.DRAWING:
		current_state = State.IDLE

		if sample_timer:
			sample_timer.stop()
		
		if not loop_detected_flag:
			print("Looping stopped without forming a loop. Clearing path.")
			_clear_path()


func _on_sample_timer_timeout() -> void:
	if current_state == State.DRAWING and not loop_detected_flag:
		var current_point_3d = _get_ground_position()

		if current_point_3d:
			if points_buffer_3d.is_empty() or current_point_3d.distance_to(points_buffer_3d[-1]) > min_point_distance_for_collection:
				points_buffer_3d.append(current_point_3d)
				points_buffer_2d.append(Vector2(current_point_3d.x, current_point_3d.z))
				if loop_path and loop_path.curve:
					loop_path.curve.add_point(current_point_3d)


func _update_realtime_loop_detection() -> void:
	if points_buffer_2d.size() < min_points_for_loop:
		return

	var current_player_pos_2d = Vector2(player.global_position.x, player.global_position.z)
	var newest_segment_p1 = points_buffer_2d[-1]
	var newest_segment_p2 = current_player_pos_2d

	# 1. Check for 'P' Shape (Self-Intersection)
	for i in range(points_buffer_2d.size() - 2):
		var old_segment_p1 = points_buffer_2d[i]
		var old_segment_p2 = points_buffer_2d[i + 1]

		var intersection_point = Geometry2D.segment_intersects_segment(newest_segment_p1, newest_segment_p2, old_segment_p1, old_segment_p2)

		if intersection_point != null:
			print("Loop detected by real-time self-intersection!")
			var loop_polygon = PackedVector2Array([intersection_point])
			loop_polygon.append_array(points_buffer_2d.slice(i + 1))
			loop_polygon.append(current_player_pos_2d)
			_handle_loop_completion(loop_polygon)
			return

	# 2. Check for 'O' Shape (Proximity to Start)
	var first_point_2d = points_buffer_2d[0]
	if first_point_2d.distance_to(current_player_pos_2d) < min_loop_detection_distance:
		print("Loop detected by real-time proximity!")
		var loop_polygon = points_buffer_2d.duplicate()
		loop_polygon.append(current_player_pos_2d)
		_handle_loop_completion(loop_polygon)
		return


func _get_ground_position() -> Vector3:
	return player.global_position


enum LoopType { PROXIMITY_CLOSURE, SELF_INTERSECTION }


func _handle_loop_completion(loop_polygon_2d: PackedVector2Array) -> void:
	if loop_detected_flag: return
	loop_detected_flag = true
	current_state = State.IDLE
	sample_timer.stop()
	_play_glow_effect(loop_polygon_2d)

	print("Loop Completed! Polygon has %d points." % loop_polygon_2d.size())

	loop_completed.emit(loop_polygon_2d)
	loop_area.set_polygon(loop_polygon_2d)
	
	detected_loops_buffer.append(loop_polygon_2d)

	_clear_path()


func _clear_path() -> void:
	points_buffer_3d.clear()
	points_buffer_2d.clear()
	if loop_path and loop_path.curve:
		loop_path.curve.clear_points()


func _play_glow_effect(polygon: PackedVector2Array):
	var triangle_indices = Geometry2D.triangulate_polygon(polygon)
	var vertices_3d = PackedVector3Array()
	for point in polygon:
		vertices_3d.append(Vector3(point.x, _get_ground_position().z, point.y))
		
	var array_mesh = ArrayMesh.new()
	var mesh_data = []
	mesh_data.resize(Mesh.ARRAY_MAX)
	mesh_data[Mesh.ARRAY_VERTEX] = vertices_3d
	mesh_data[Mesh.ARRAY_INDEX] = triangle_indices
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	glow_effect_mesh.mesh = array_mesh
	
	var material = glow_effect_mesh.material_override as StandardMaterial3D
	if not material: return
	
	var tween = create_tween()
	tween.tween_property(material, "albedo_color:a", 1.0, 0.15).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(material, "albedo_color:a", 0.0, 0.25).set_trans(Tween.TRANS_QUINT)
	tween.finished.connect(func(): glow_effect_mesh.mesh = null)

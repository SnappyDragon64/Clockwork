class_name LoopComponent extends Node


signal loop_completed(points: PackedVector2Array)

@export var min_points_for_loop: int = 4
@export var min_loop_detection_distance: float = 0.5
@export var point_collection_interval: float = 0.1
@export var self_intersection_tolerance: float = 0.01
@export var min_point_distance_for_collection: float = 0.1

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
	
	SceneSetManager.scene_set_initialized.connect(_on_scene_set_initialized)


func _on_scene_set_initialized(_context: SceneSetContext):
	loop_path = loop_path_scene.instantiate()
	loop_area = loop_area_scene.instantiate()
	
	EventBus.publish(Events.SPAWN_ENTITY, { "entity": loop_path })
	EventBus.publish(Events.SPAWN_ENTITY, { "entity": loop_area })


func _process(delta: float) -> void:
	if current_state == State.DRAWING and not loop_detected_flag:
		_check_current_segment_for_loop()


func _on_loop_started() -> void:
	if current_state == State.IDLE:
		current_state = State.DRAWING
		points_buffer_3d.clear()
		points_buffer_2d.clear()
		if loop_path and loop_path.curve:
			loop_path.curve.clear_points()
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
	if current_state == State.DRAWING:
		current_state = State.IDLE

		if sample_timer:
			sample_timer.stop()

		if not loop_detected_flag:
			if points_buffer_3d.size() >= min_points_for_loop:
				var first_point_2d = points_buffer_2d[0]
				var last_point_2d = points_buffer_2d[-1]

				if first_point_2d.distance_to(last_point_2d) < min_loop_detection_distance:
					print("Loop closed by proximity at stop! (No real-time detection)")
					_handle_loop_completion(LoopType.PROXIMITY_CLOSURE)

		points_buffer_3d.clear()
		points_buffer_2d.clear()
		if loop_path and loop_path.curve:
			loop_path.curve.clear_points()
		print("Detected loops flushed. Count: %d" % detected_loops_buffer.size())
		detected_loops_buffer.clear()


func _on_sample_timer_timeout() -> void:
	if current_state == State.DRAWING and not loop_detected_flag:
		var current_point_3d = _get_ground_position()

		if current_point_3d:
			if points_buffer_3d.is_empty() or current_point_3d.distance_to(points_buffer_3d[-1]) > min_point_distance_for_collection:
				points_buffer_3d.append(current_point_3d)
				points_buffer_2d.append(Vector2(current_point_3d.x, current_point_3d.z))
				if loop_path and loop_path.curve:
					loop_path.curve.add_point(current_point_3d)

				_check_for_incremental_loop_on_sample()


func _get_ground_position() -> Vector3:
	return player.global_position


enum LoopType { PROXIMITY_CLOSURE, SELF_INTERSECTION }


func _handle_loop_completion(type: LoopType, intersection_index: int = -1, intersection_point_2d: Vector2 = Vector2()) -> void:
	if not loop_detected_flag:
		loop_detected_flag = true
		current_state = State.IDLE
		sample_timer.stop()

		var loop_points_2d: PackedVector2Array

		match type:
			LoopType.PROXIMITY_CLOSURE:
				loop_points_2d = points_buffer_2d.duplicate()
				if not loop_points_2d.is_empty() and loop_points_2d[-1] != loop_points_2d[0]:
					loop_points_2d.append(loop_points_2d[0])
				print("Loop Detected by Proximity! Points count: %d" % loop_points_2d.size())

			LoopType.SELF_INTERSECTION:
				if intersection_index == -1:
					print("Error: Self-intersection loop detected without index.")
					loop_points_2d = points_buffer_2d.duplicate()
					return

				for i in range(intersection_index, points_buffer_2d.size() - 1):
					loop_points_2d.append(points_buffer_2d[i])

				#var y_avg = (points_buffer_2d[intersection_index].y + points_buffer_2d[intersection_index + 1].y +
							 #points_buffer_2d[-2].y + points_buffer_2d[-1].y) / 4.0
				loop_points_2d.append(Vector2(intersection_point_2d.x, intersection_point_2d.y))

				if not loop_points_2d.is_empty() and loop_points_2d[-1] != loop_points_2d[0]:
					loop_points_2d.append(loop_points_2d[0])

				print("Loop Detected by Self-Intersection! Points count: %d" % loop_points_2d.size())

		loop_completed.emit(loop_points_2d)
		loop_area.set_polygon(loop_points_2d)
		detected_loops_buffer.append(loop_points_2d)
		points_buffer_3d.clear()
		points_buffer_2d.clear()
		if loop_path and loop_path.curve:
			loop_path.curve.clear_points()


func _check_current_segment_for_loop() -> void:
	if points_buffer_3d.size() < min_points_for_loop - 1:
		return

	var current_player_pos_3d = _get_ground_position()
	var current_player_pos_2d = Vector2(current_player_pos_3d.x, current_player_pos_3d.z)
	var last_sampled_point_2d = points_buffer_2d[-1]

	var first_point_2d = points_buffer_2d[0]
	if first_point_2d.distance_to(current_player_pos_2d) < min_loop_detection_distance:
		print("Loop detected by real-time proximity!")
		_handle_loop_completion(LoopType.PROXIMITY_CLOSURE)
		return

	var current_segment_p1 = last_sampled_point_2d
	var current_segment_p2 = current_player_pos_2d

	for i in range(points_buffer_2d.size() - 1):
		var old_segment_p1 = points_buffer_2d[i]
		var old_segment_p2 = points_buffer_2d[i+1]

		if i + 1 == points_buffer_2d.size() - 1:
			continue

		var intersection_result = Geometry2D.segment_intersects_segment(current_segment_p1, current_segment_p2, old_segment_p1, old_segment_p2)
		if intersection_result != null:
			print("Loop detected by real-time self-intersection!")
			_handle_loop_completion(LoopType.SELF_INTERSECTION, i, intersection_result)
			return


func _check_for_incremental_loop_on_sample() -> void:
	if points_buffer_3d.size() < min_points_for_loop:
		return

	var n = points_buffer_3d.size()
	if n < 2:
		return

	var new_sampled_segment_p1 = points_buffer_2d[-2]
	var new_sampled_segment_p2 = points_buffer_2d[-1]

	for i in range(n - 3):
		var old_segment_p1 = points_buffer_2d[i]
		var old_segment_p2 = points_buffer_2d[i+1]

		var intersection_result = Geometry2D.segment_intersects_segment(new_sampled_segment_p1, new_sampled_segment_p2, old_segment_p1, old_segment_p2)
		if intersection_result != null:
			print("Loop detected by self-intersection from new sample!")
			_handle_loop_completion(LoopType.SELF_INTERSECTION, i, intersection_result)
			return

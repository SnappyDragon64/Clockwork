class_name LoopArea extends Area3D





func set_polygon(polygon: PackedVector2Array):
	$CollisionPolygon3D.set_polygon(polygon)
	await get_tree().create_timer(1.0).timeout
	await get_tree().process_frame
	set_polygon([])

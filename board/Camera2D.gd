extends Camera2D

class_name BoardCamera

signal touch_tapped(screen_position: Vector2)

const SCROLL_BORDER = 20
const SCROLL_SPEED = 600.0
const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.8
const MAX_ZOOM = 2
const MAP_EDGE_BORDER = 500
const TOUCH_TAP_MAX_MOVEMENT = 12.0
var _zoom_level = 1.5
var _zoom_tween: Tween
var edge_scrolling_enabled = true
var _touch_points = {}
var _raw_touch_points = {}
var _primary_touch_index = -1
var _touch_movement = 0.0
var _touch_used_multiple_fingers = false
var _suppress_mouse_until_msec = 0

func _ready() -> void:
	zoom = _world_zoom(_zoom_level)

func set_map_limits(map_start: Vector2, map_end: Vector2) -> void:
	# Expand the native Camera2D limits too. Otherwise Godot clamps the rendered
	# view back to the original map edge after the custom position clamp runs.
	set_limit(SIDE_LEFT, roundi(map_start.x - MAP_EDGE_BORDER))
	set_limit(SIDE_TOP, roundi(map_start.y - MAP_EDGE_BORDER))
	set_limit(SIDE_RIGHT, roundi(map_end.x + MAP_EDGE_BORDER))
	set_limit(SIDE_BOTTOM, roundi(map_end.y + MAP_EDGE_BORDER))

func _input(event):
	if event is InputEventScreenDrag:
		if _raw_touch_points.has(event.index):
			var previous_position: Vector2 = _raw_touch_points[event.index]
			_touch_movement += event.position.distance_to(previous_position)
			_raw_touch_points[event.index] = event.position
		return
	if !(event is InputEventScreenTouch):
		return
	if event.pressed:
		_raw_touch_points[event.index] = event.position
		if _raw_touch_points.size() > 1:
			_touch_used_multiple_fingers = true
	else:
		_raw_touch_points.erase(event.index)
		_suppress_mouse_until_msec = Time.get_ticks_msec() + 250

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
		return
	if event is InputEventScreenDrag:
		_handle_screen_drag(event)
		return
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level + ZOOM_SPEED)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level - ZOOM_SPEED)

func _handle_screen_touch(event: InputEventScreenTouch):
	if event.pressed:
		if _touch_points.is_empty():
			_primary_touch_index = event.index
			_touch_movement = 0.0
			_touch_used_multiple_fingers = false
		_touch_points[event.index] = event.position
		if _touch_points.size() > 1:
			_touch_used_multiple_fingers = true
			_stop_zoom_tween()
		get_viewport().set_input_as_handled()
		return

	var is_tap = (
		event.index == _primary_touch_index
		&& _touch_points.size() == 1
		&& !_touch_used_multiple_fingers
		&& _touch_movement <= TOUCH_TAP_MAX_MOVEMENT
	)
	_touch_points.erase(event.index)
	if is_tap:
		touch_tapped.emit(event.position)
	if _touch_points.is_empty():
		_primary_touch_index = -1
		_touch_movement = 0.0
		_touch_used_multiple_fingers = false
	get_viewport().set_input_as_handled()

func _handle_screen_drag(event: InputEventScreenDrag):
	if !_touch_points.has(event.index):
		return
	var old_center = _get_touch_center()
	var old_distance = _get_pinch_distance()
	var old_position: Vector2 = _touch_points[event.index]
	_touch_points[event.index] = event.position
	var drag_delta = event.position - old_position

	if _touch_points.size() == 1:
		if _touch_movement > TOUCH_TAP_MAX_MOVEMENT:
			_pan_by_screen_delta(drag_delta)
	else:
		_touch_used_multiple_fingers = true
		var new_center = _get_touch_center()
		var new_distance = _get_pinch_distance()
		_pan_by_screen_delta(new_center - old_center)
		if old_distance > 0.0 && new_distance > 0.0:
			_apply_touch_zoom(
				_zoom_level * new_distance / old_distance,
				new_center
			)
	get_viewport().set_input_as_handled()

func _get_touch_center() -> Vector2:
	if _touch_points.is_empty():
		return Vector2.ZERO
	var center = Vector2.ZERO
	for touch_position in _touch_points.values():
		center += touch_position
	return center / float(_touch_points.size())

func has_active_touch() -> bool:
	return !_touch_points.is_empty()

func should_suppress_mouse_click() -> bool:
	return (
		!_raw_touch_points.is_empty()
		|| Time.get_ticks_msec() < _suppress_mouse_until_msec
	)

func _get_pinch_distance() -> float:
	if _touch_points.size() < 2:
		return 0.0
	var positions = _touch_points.values()
	var first_position: Vector2 = positions[0]
	var second_position: Vector2 = positions[1]
	return first_position.distance_to(second_position)

func _pan_by_screen_delta(screen_delta: Vector2):
	var world_delta = Vector2(
		screen_delta.x,
		screen_delta.y / Globals.WORLD_DEPTH_SCALE
	)
	position -= world_delta / zoom.x
	_clamp_to_map(get_viewport_rect().size)
	force_update_scroll()

func _apply_touch_zoom(value: float, screen_anchor: Vector2):
	var board = get_tree().get_first_node_in_group("board") as Board
	var world_anchor_before = Vector2.ZERO
	if board != null:
		world_anchor_before = board.screen_to_world_position(screen_anchor)
	_stop_zoom_tween()
	_zoom_level = clampf(value, MIN_ZOOM, MAX_ZOOM)
	zoom = _world_zoom(_zoom_level)
	force_update_scroll()
	if board != null:
		var world_anchor_after = board.screen_to_world_position(screen_anchor)
		position += world_anchor_before - world_anchor_after
	_clamp_to_map(get_viewport_rect().size)
	force_update_scroll()
	if board != null:
		board.update_all_billboards()

func _stop_zoom_tween():
	if _zoom_tween != null && _zoom_tween.is_valid():
		_zoom_tween.kill()
	_zoom_tween = null


func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	_stop_zoom_tween()
	_zoom_tween = create_tween()
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	_zoom_tween.set_ease(Tween.EASE_OUT)
	_zoom_tween.set_trans(Tween.TRANS_SINE)
	_zoom_tween.tween_method(_apply_zoom, zoom.x, _zoom_level, 0.2)


func _apply_zoom(value: float) -> void:
	zoom = _world_zoom(value)
	force_update_scroll()
	var board = get_tree().get_first_node_in_group("board") as Board
	if board != null:
		board.update_all_billboards()


func _world_zoom(value: float) -> Vector2:
	return Vector2(value, value * Globals.WORLD_DEPTH_SCALE)

func _process(delta: float) -> void:
	if !edge_scrolling_enabled || OS.has_feature("mobile") || !_touch_points.is_empty():
		return

	# Mouse positions use viewport coordinates, so the edge checks must use the
	# viewport size too. DisplayServer.window_get_size() is in a different
	# coordinate space when stretch or display scaling is enabled.
	var viewport_size := get_viewport_rect().size
	var mouse := get_viewport().get_mouse_position()
	var scroll_direction := Vector2.ZERO

	if mouse.x <= SCROLL_BORDER:
		scroll_direction.x = - (SCROLL_BORDER - mouse.x) / SCROLL_BORDER
	elif mouse.x >= viewport_size.x - SCROLL_BORDER:
		scroll_direction.x = (mouse.x - (viewport_size.x - SCROLL_BORDER)) / SCROLL_BORDER

	if mouse.y <= SCROLL_BORDER:
		scroll_direction.y = - (SCROLL_BORDER - mouse.y) / SCROLL_BORDER
	elif mouse.y >= viewport_size.y - SCROLL_BORDER:
		scroll_direction.y = (mouse.y - (viewport_size.y - SCROLL_BORDER)) / SCROLL_BORDER

	# Keep corner scrolling at the same maximum speed as scrolling along one edge.
	scroll_direction = scroll_direction.limit_length(1.0)
	# The camera compresses the vertical world axis. Compensate movement so edge
	# scrolling still has the same apparent speed in every screen direction.
	var world_scroll_direction = Vector2(
		scroll_direction.x,
		scroll_direction.y / Globals.WORLD_DEPTH_SCALE
	)
	position += world_scroll_direction * SCROLL_SPEED * delta / zoom.x
	_clamp_to_map(viewport_size)
	force_update_scroll()


func _clamp_to_map(viewport_size: Vector2) -> void:
	var half_view = viewport_size * 0.5 / zoom
	position.x = _clamp_axis(position.x, limit_left, limit_right, half_view.x)
	position.y = _clamp_axis(position.y, limit_top, limit_bottom, half_view.y)


func _clamp_axis(value: float, lower_limit: float, upper_limit: float, half_view: float) -> float:
	var minimum := lower_limit + half_view
	var maximum := upper_limit - half_view
	if minimum > maximum:
		return (lower_limit + upper_limit) * 0.5
	return clampf(value, minimum, maximum)

extends Camera2D

class_name BoardCamera

const SCROLL_BORDER = 20
const SCROLL_SPEED = 600.0
const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.8
const MAX_ZOOM = 2
const MAP_EDGE_BORDER = 500
var _zoom_level = 1.5
var _zoom_tween: Tween
var edge_scrolling_enabled = true

func _ready() -> void:
	zoom = _world_zoom(_zoom_level)

func set_map_limits(map_start: Vector2, map_end: Vector2) -> void:
	# Expand the native Camera2D limits too. Otherwise Godot clamps the rendered
	# view back to the original map edge after the custom position clamp runs.
	set_limit(SIDE_LEFT, roundi(map_start.x - MAP_EDGE_BORDER))
	set_limit(SIDE_TOP, roundi(map_start.y - MAP_EDGE_BORDER))
	set_limit(SIDE_RIGHT, roundi(map_end.x + MAP_EDGE_BORDER))
	set_limit(SIDE_BOTTOM, roundi(map_end.y + MAP_EDGE_BORDER))

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level + ZOOM_SPEED)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level - ZOOM_SPEED)


func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	if _zoom_tween != null && _zoom_tween.is_valid():
		_zoom_tween.kill()
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
	if !edge_scrolling_enabled:
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

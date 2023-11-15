extends Camera2D

const SCROLL_BORDER = 70
const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.8 
const MAX_ZOOM = 2
var _zoom_level = 1.5

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level + ZOOM_SPEED)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level - ZOOM_SPEED)


func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, MIN_ZOOM, MAX_ZOOM)
	var tween = create_tween()
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "zoom", Vector2(_zoom_level, _zoom_level),	0.2)

func _process(delta):
	var window = DisplayServer.window_get_size()
	var mouse =  (get_tree().get_first_node_in_group("board_ui") as CanvasLayer).get_viewport().get_mouse_position()
	mouse.x = clamp(mouse.x, 0, window.x)
	mouse.y = clamp(mouse.y, 0, window.y)
	var movex = 0
	var movey = 0
	if mouse.x <= SCROLL_BORDER:
		movex = (SCROLL_BORDER - mouse.x) * -1
	elif mouse.x >= window.x - SCROLL_BORDER:
		movex = (SCROLL_BORDER - (window.x-mouse.x))
	if mouse.y <= SCROLL_BORDER:
		movey = (SCROLL_BORDER - mouse.y) * -1
	elif mouse.y >= window.y - SCROLL_BORDER:
		movey = (SCROLL_BORDER - (window.y-mouse.y))
	var speed = 0.2 / zoom.x
	position.x+=movex*speed
	position.y+=movey*speed
	var viewport_size = get_viewport().size
	var x = (viewport_size.x/2) / zoom.x
	var y = (viewport_size.y/2) / zoom.y
	position.x = clamp(position.x, limit_left+x, limit_right-x)
	position.y = clamp(position.y, limit_top+y, limit_bottom-y)
	

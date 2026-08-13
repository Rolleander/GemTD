extends Node2D

class_name EnemyHitEffect

const LIFETIME = 0.26

func _ready():
	queue_redraw()
	var start_scale = scale
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", start_scale * 1.3, LIFETIME)
	tween.tween_property(self, "modulate:a", 0.0, LIFETIME)
	tween.chain().tween_callback(queue_free)

func _draw():
	var burst_points = PackedVector2Array([
		Vector2(0.0, -10.0),
		Vector2(1.8, -3.2),
		Vector2(7.5, -6.0),
		Vector2(3.5, -1.2),
		Vector2(10.0, 1.0),
		Vector2(3.0, 2.2),
		Vector2(5.5, 8.0),
		Vector2(0.5, 4.0),
		Vector2(-4.0, 9.0),
		Vector2(-2.8, 2.5),
		Vector2(-9.0, 4.0),
		Vector2(-3.8, 0.0),
		Vector2(-7.0, -6.5),
		Vector2(-1.8, -3.2),
	])
	draw_colored_polygon(burst_points, Color(1.0, 0.66, 0.04, 0.95))
	draw_circle(Vector2.ZERO, 3.2, Color(1.0, 0.96, 0.55, 1.0))
	draw_circle(Vector2(-0.5, -0.7), 1.35, Color.WHITE)

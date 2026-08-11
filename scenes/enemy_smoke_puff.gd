extends Node2D

class_name EnemySmokePuff

var board: Board
var world_position = Vector2.ZERO
var velocity = Vector2.ZERO
var age = 0.0
var lifetime = 1.0
var base_scale = 0.1
var sprite: Sprite2D

func setup(
	board_instance: Board,
	texture: Texture2D,
	spawn_position: Vector2,
	spawn_velocity: Vector2,
	puff_lifetime: float,
	puff_scale: float
):
	board = board_instance
	world_position = spawn_position
	velocity = spawn_velocity
	lifetime = puff_lifetime
	base_scale = puff_scale
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.modulate = Color(0.18, 0.17, 0.16, 0.48)
	sprite.scale = Vector2.ONE * base_scale
	add_child(sprite)
	_sync_projection()

func _process(delta):
	age += delta
	if age >= lifetime:
		queue_free()
		return
	world_position += velocity * delta
	velocity.y -= 2.0 * delta
	var progress = clampf(age / lifetime, 0.0, 1.0)
	sprite.scale = Vector2.ONE * base_scale * lerpf(1.0, 1.8, progress)
	sprite.modulate.a = 0.48 * (1.0 - smoothstep(0.15, 1.0, progress))
	_sync_projection()

func _sync_projection():
	if !is_instance_valid(board):
		return
	board.update_billboard(self, world_position)
	# Smoke trails behind the enemy graphic without dropping back into the
	# shader-warped map canvas.
	z_index -= 1

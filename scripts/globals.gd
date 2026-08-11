extends Node

const GRID_SIZE = 24
const TILE_SIZE = GRID_SIZE * 2
## Vertical foreshortening and perspective used by the 2.5D world view.
const WORLD_DEPTH_SCALE = 1.0
const BILLBOARD_Y_SCALE = 1.0 / WORLD_DEPTH_SCALE
const WORLD_FAR_WIDTH = 1.0
const WORLD_NEAR_WIDTH = 1.4
const WORLD_FAR_Y = 0.0
const WORLD_NEAR_Y = 1.0
const ATTACK_TRAIL_Z_INDEX = 3000
const ATTACK_PROJECTILE_Z_INDEX = 3001
const ATTACK_EFFECT_Z_INDEX = 3002

## Converts a displayed, perspective-warped viewport point back to the flat
## viewport position used by Camera2D and all gameplay calculations.
func unwarp_world_screen_position(screen_position: Vector2, viewport_size: Vector2) -> Vector2:
	if viewport_size.x <= 0.0 || viewport_size.y <= 0.0:
		return screen_position
	var uv = screen_position / viewport_size
	var perspective_denominator = WORLD_FAR_WIDTH / WORLD_NEAR_WIDTH
	var perspective_curve = perspective_denominator - 1.0
	var vertical_scale = WORLD_NEAR_Y * perspective_denominator - WORLD_FAR_Y
	var source_denominator = uv.y * perspective_curve - vertical_scale
	if is_zero_approx(source_denominator):
		return screen_position
	var source_y = (WORLD_FAR_Y - uv.y) / source_denominator
	var homogeneous_scale = 1.0 + perspective_curve * source_y
	var source_uv = Vector2(
		0.5 + (uv.x - 0.5) * homogeneous_scale / WORLD_FAR_WIDTH,
		source_y
	)
	return source_uv * viewport_size

## Projects an ordinary Camera2D screen position into the trapezoid view.
func warp_world_screen_position(screen_position: Vector2, viewport_size: Vector2) -> Vector2:
	if viewport_size.x <= 0.0 || viewport_size.y <= 0.0:
		return screen_position
	var uv = screen_position / viewport_size
	var perspective_denominator = WORLD_FAR_WIDTH / WORLD_NEAR_WIDTH
	var perspective_curve = perspective_denominator - 1.0
	var vertical_scale = WORLD_NEAR_Y * perspective_denominator - WORLD_FAR_Y
	var homogeneous_scale = 1.0 + perspective_curve * uv.y
	var warped_uv = Vector2(
		0.5 + WORLD_FAR_WIDTH * (uv.x - 0.5) / homogeneous_scale,
		(vertical_scale * uv.y + WORLD_FAR_Y) / homogeneous_scale
	)
	return warped_uv * viewport_size

## Uniform perspective size for an upright billboard at this source position.
func world_billboard_perspective_scale(screen_position: Vector2, viewport_size: Vector2) -> float:
	if viewport_size.y <= 0.0:
		return 1.0
	var source_y = screen_position.y / viewport_size.y
	var perspective_denominator = WORLD_FAR_WIDTH / WORLD_NEAR_WIDTH
	var perspective_curve = perspective_denominator - 1.0
	var homogeneous_scale = 1.0 + perspective_curve * source_y
	return WORLD_FAR_WIDTH / homogeneous_scale

const Quality = preload("res://scripts/gem_quality.gd").GemQuality
const Type = preload("res://scripts/gem_types.gd").GemType
var loader = ResourcesLoader.new()

var gem_types: Array[GemTypeInfo] = []
var gem_qualities: Array[GemQualityInfo] = []
var roll_chances: Array[RollChances] = []
var special_gems: Array[SpecialGem] = []

func _ready() -> void:
	loader.load_resources_from_folder(gem_types, "res://resources/gem_types")
	loader.load_resources_from_folder(gem_qualities, "res://resources/gem_qualities")
	loader.load_resources_from_folder(roll_chances, "res://resources/roll_chances")
	loader.load_resources_from_folder(special_gems, "res://resources/special_gems")

func get_gem_info(type: Type) -> GemTypeInfo:
	for t in gem_types:
		if t.type == type:
			return t
	return null

func get_quality_info(quality: Quality) -> GemQualityInfo:
	for q in gem_qualities:
		if q.quality == quality:
			return q
	return null

func get_roll_chances(level) -> RollChances:
	for r in roll_chances:
		if r.level == level:
			return r
	return null

func get_special_gems() -> Array[SpecialGem]:
	return special_gems

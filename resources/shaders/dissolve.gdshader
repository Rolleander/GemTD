shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float seed : hint_range(0.01, 1.0, 0.01) = 0.5;
uniform vec2 direction = vec2(-0.5, 0.0);
uniform float mask_vignette_strength : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec2 mask_vignette_center = vec2(0.5, 0.3);
uniform bool use_region = false;
uniform vec2 region_position_px = vec2(0.0);
uniform vec2 region_size_px = vec2(1.0);

float random_value(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 region_min_uv = vec2(0.0);
	vec2 region_size_uv = vec2(1.0);
	vec2 local_uv = UV;
	if (use_region) {
		region_min_uv = region_position_px * TEXTURE_PIXEL_SIZE;
		region_size_uv = max(region_size_px * TEXTURE_PIXEL_SIZE, vec2(0.000001));
		local_uv = (UV - region_min_uv) / region_size_uv;
	}

	vec2 random_offset = vec2(
		random_value(local_uv * seed),
		random_value(local_uv.yx * seed + vec2(17.17, 43.31))
	);
	random_offset.x = clamp(random_offset.x, 0.0, 0.5);
	random_offset.y = clamp(random_offset.y, 0.0, 1.5);

	vec2 displaced_local_uv = local_uv
		+ random_offset * strength
		+ direction * strength;
	vec2 texture_uv = region_min_uv + displaced_local_uv * region_size_uv;
	vec2 region_max_uv = region_min_uv + region_size_uv;
	float inside_region = step(region_min_uv.x, texture_uv.x)
		* step(region_min_uv.y, texture_uv.y)
		* step(texture_uv.x, region_max_uv.x)
		* step(texture_uv.y, region_max_uv.y);

	vec4 sprite_color = texture(TEXTURE, texture_uv) * COLOR;
	float vignette_distance = distance(local_uv, mask_vignette_center);
	float dissolve_alpha = sprite_color.a
		- clamp(random_offset.x * strength, 0.0, 3.0)
		- strength
		- vignette_distance * strength * mask_vignette_strength * 3.0;
	sprite_color.a = clamp(dissolve_alpha, 0.0, 1.0) * inside_region;
	COLOR = sprite_color;
}

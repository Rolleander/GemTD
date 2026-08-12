shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform bool show_debug_colors = false;
uniform vec2 center = vec2(0.5);
uniform float radius : hint_range(0.01, 2.0, 0.01) = 1.0;
uniform float distortion_strength : hint_range(0.0, 2.0, 0.01) = 0.9;
uniform float attenuation : hint_range(0.0, 30.0, 0.1) = 10.0;
uniform float effect_strength : hint_range(0.0, 2.0, 0.01) = 1.0;

void fragment() {
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect_ratio = viewport_size.x / max(viewport_size.y, 1.0);
	vec2 direction = UV - center;
	// Measure distance in aspect-corrected space so a full-screen ColorRect
	// produces a circular black-hole field rather than an oval one.
	vec2 aspect_direction = direction;
	aspect_direction.x *= aspect_ratio;
	float distance_from_center = length(aspect_direction);
	float normalized_distance = distance_from_center / max(radius, 0.0001);

	float safe_distance = max(normalized_distance, 0.0001);
	float inside_mask = 1.0 - step(1.0, normalized_distance);
	float edge_falloff = pow(
		max(1.0 - normalized_distance, 0.0001),
		attenuation
	) * inside_mask;
	vec2 distortion = direction
		* pow(safe_distance, -distortion_strength)
		* edge_falloff
		* effect_strength;
	vec2 sample_uv = clamp(
		SCREEN_UV - distortion,
		vec2(0.0),
		vec2(1.0)
	);
	COLOR = texture(screen_texture, sample_uv);

	if (show_debug_colors) {
		vec2 debug_direction = aspect_direction / max(radius, 0.0001);
		COLOR = vec4(debug_direction * 0.5 + 0.5, 0.0, 1.0);
	}
}

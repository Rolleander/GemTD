// Converted/modified from ShaderToy: https://www.shadertoy.com/view/ldBXDD
// Attach this shader to a ColorRect covering the area that should ripple.

shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float wave_count : hint_range(1.0, 40.0, 1.0) = 20.0;
uniform float speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float height : hint_range(0.0, 0.1, 0.001) = 0.003;
uniform vec2 center = vec2(0.5);
uniform float inner_fade : hint_range(0.0, 0.25, 0.001) = 0.01;
uniform float outer_fade : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect_ratio = viewport_size.x / max(viewport_size.y, 1.0);
	vec2 centered_position = (UV - center) * 2.0;
	centered_position.x *= aspect_ratio;
	float distance_from_center = length(centered_position);

	vec2 ripple_direction = centered_position
		/ max(distance_from_center, 0.0001);
	// Convert the direction back from aspect-corrected space to screen UV space.
	ripple_direction.x /= aspect_ratio;

	float center_mask = smoothstep(0.0, inner_fade, distance_from_center);
	float edge_mask = 1.0;
	if (outer_fade > 0.0) {
		edge_mask = 1.0 - smoothstep(
			max(1.0 - outer_fade, 0.0),
			1.0,
			distance_from_center
		);
	}
	float displacement = cos(
		distance_from_center * wave_count - TIME * speed
	) * height * center_mask * edge_mask;
	vec2 sample_uv = SCREEN_UV + ripple_direction * displacement;
	vec4 screen_color = texture(screen_texture, sample_uv);

	COLOR = screen_color * COLOR;
}

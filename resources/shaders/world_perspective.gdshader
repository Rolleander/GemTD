shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float far_width = 1.0;
uniform float near_width = 1.18;
uniform float far_y = 0.0;
uniform float near_y = 1.0;

void fragment() {
	vec2 warped_uv = SCREEN_UV;
	float perspective_denominator = far_width / near_width;
	float perspective_curve = perspective_denominator - 1.0;
	float vertical_scale = near_y * perspective_denominator - far_y;
	float source_denominator = warped_uv.y * perspective_curve - vertical_scale;
	float source_y = (far_y - warped_uv.y) / source_denominator;
	float homogeneous_scale = 1.0 + perspective_curve * source_y;
	vec2 source_uv = vec2(
		0.5 + (warped_uv.x - 0.5) * homogeneous_scale / far_width,
		source_y
	);

	vec4 sampled = vec4(0.0);
	if (source_uv.x >= 0.0 && source_uv.x <= 1.0 && source_uv.y >= 0.0 && source_uv.y <= 1.0) {
		sampled = textureLod(screen_texture, source_uv, 0.0);
	}
	if (sampled.a > 0.0001) {
		sampled.rgb /= sampled.a;
	}
	COLOR *= sampled;
}

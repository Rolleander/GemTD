shader_type canvas_item;
render_mode blend_add;

uniform float radius : hint_range(0.0, 1.0, 0.01) = 0.7;
uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform vec4 color : source_color = vec4(0.9, 0.4, 0.1, 1.0);
uniform float brightness : hint_range(0.0, 15.0, 0.01) = 5.0;
uniform float angular_speed : hint_range(-5.0, 5.0, 0.01) = 2.5;
uniform float radial_speed : hint_range(-5.0, 5.0, 0.01) = 1.4;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform sampler2D noise : repeat_enable, filter_linear;

void fragment() {
	vec2 centered_uv = vec2(0.5) - UV;
	float distance_from_center = length(centered_uv) * 2.0;
	float angle = atan(centered_uv.y, centered_uv.x) + TIME * angular_speed;
	float safe_thickness = max(thickness, 0.0001);
	float thickness_ratio = 1.0
		- abs(distance_from_center - max(0.0, radius)) / safe_thickness;
	vec2 polar_uv = fract(vec2(
		angle / 6.28318530718,
		distance_from_center + TIME * radial_speed
	));
	vec3 noise_color = texture(noise, polar_uv).rgb;
	float ring_mask = clamp(thickness_ratio, 0.0, 1.0);
	float noise_intensity = (noise_color.r + noise_color.g + noise_color.b) / 3.0;

	vec4 ring_color = ring_mask * brightness * color;
	ring_color.a = alpha * noise_intensity * ring_mask * color.a;
	COLOR = ring_color;
}

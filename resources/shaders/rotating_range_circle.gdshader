shader_type canvas_item;

uniform float section_count : hint_range(1.0, 64.0, 1.0) = 16.0;
uniform float section_ratio : hint_range(0.05, 0.95, 0.01) = 0.58;
uniform float rotation_speed : hint_range(-2.0, 2.0, 0.01) = 0.18;
uniform float edge_softness : hint_range(0.0, 0.25, 0.005) = 0.04;
uniform float pulse_strength : hint_range(0.0, 1.0, 0.01) = 0.12;
uniform float pulse_speed : hint_range(0.0, 10.0, 0.1) = 2.4;

void fragment() {
	vec4 ring = texture(TEXTURE, UV) * COLOR;
	if (ring.a <= 0.001) {
		discard;
	}

	vec2 centered_uv = UV - vec2(0.5);
	float angle = atan(centered_uv.y, centered_uv.x);
	float normalized_angle = angle / 6.28318530718 + 0.5;
	float section_phase = fract(
		normalized_angle * max(section_count, 1.0)
		- TIME * rotation_speed
	);

	// Measuring from the center of each section gives both ends the same soft
	// edge and keeps every rotating arc exactly the same length.
	float section_distance = abs(section_phase - 0.5) * 2.0;
	float softness = max(edge_softness, 0.0001);
	float section_mask = 1.0 - smoothstep(
		section_ratio,
		section_ratio + softness,
		section_distance
	);
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;

	COLOR = vec4(ring.rgb * pulse, ring.a * section_mask);
}

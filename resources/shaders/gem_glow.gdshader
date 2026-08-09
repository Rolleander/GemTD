shader_type canvas_item;

render_mode blend_add;

uniform sampler2D noise_img : repeat_enable;
uniform sampler2D noise_img2 : repeat_enable;
uniform vec4 glow_color : source_color = vec4(1.0);
uniform float quality : hint_range(0.0, 1.0) = 0.0;
uniform float rand;
uniform float speed = 0.1;
uniform float energy = 0.3;

void vertex() {
	float pulse_wave = sin(
		TIME * (1.45 + quality * 0.2)
		+ rand * 6.283185
		+ sin(TIME * 0.43 + rand) * 0.35
	);
	float pulse = 1.0 + pulse_wave * (0.085 + quality * 0.055);
	VERTEX *= pulse;
}

void fragment() {
	vec4 mask = texture(TEXTURE, UV);
	vec2 centered_uv = UV * 2.0 - 1.0;
	float radial = clamp(1.0 - length(centered_uv), 0.0, 1.0);
	float noise_a = texture(noise_img, UV + vec2(TIME * speed, rand)).r;
	float noise_b = texture(noise_img2, UV - vec2(rand, TIME * speed * 0.7)).r;
	float shimmer = mix(0.82, 1.12, noise_a * noise_b);
	float pulse_wave = sin(
		TIME * (1.55 + quality * 0.22)
		+ rand * 6.283185
		+ sin(TIME * 0.49 + rand * 2.0) * 0.4
	);
	float pulse = 0.62 + 0.43 * pulse_wave;
	float alpha = mask.a * radial * shimmer * pulse * energy;
	vec3 color = glow_color.rgb * (0.72 + quality * 0.35);
	COLOR = vec4(color, alpha);
}

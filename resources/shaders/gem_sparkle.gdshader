shader_type canvas_item;

render_mode blend_add;

uniform vec4 sparkle_color : source_color = vec4(1.0);
uniform float intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec2 flare_uv = (UV - vec2(0.5)) * 2.0;
	float radius = length(flare_uv);

	float core = 1.0 - smoothstep(0.0, 0.16, radius);
	float soft_halo = (1.0 - smoothstep(0.08, 0.55, radius)) * 0.3;
	float horizontal_streak = pow(max(0.0, 1.0 - abs(flare_uv.y)), 34.0)
		* (1.0 - smoothstep(0.08, 1.0, abs(flare_uv.x))) * 0.72;
	float vertical_streak = pow(max(0.0, 1.0 - abs(flare_uv.x)), 42.0)
		* (1.0 - smoothstep(0.06, 0.72, abs(flare_uv.y))) * 0.24;
	float halo_ring = (1.0 - smoothstep(0.0, 0.035, abs(radius - 0.32))) * 0.14;

	float flare = clamp(core + soft_halo + horizontal_streak + vertical_streak + halo_ring, 0.0, 1.0);
	vec3 flare_color = mix(sparkle_color.rgb, vec3(1.0), core * 0.72);
	COLOR = vec4(flare_color * (0.8 + core * 0.75), flare * sparkle_color.a * intensity);
}

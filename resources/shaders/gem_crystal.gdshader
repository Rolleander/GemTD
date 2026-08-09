shader_type canvas_item;

// The gem has its own controlled reflections below. Keeping the sprite
// unshaded prevents its PointLight2D from washing bright textures toward white;
// that light still illuminates the map normally.
render_mode unshaded;

uniform vec4 gem_color : source_color = vec4(1.0);
uniform float quality : hint_range(0.0, 1.0) = 0.0;
uniform float rand = 0.0;

float random_value(float seed) {
	return fract(sin(seed * 127.1 + 311.7) * 43758.5453);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a <= 0.001) {
		COLOR = vec4(0.0);
	} else {
		vec2 pixel = UV / TEXTURE_PIXEL_SIZE;
		float phase = rand * 6.283185;
		float irregular_time = TIME * (0.44 + quality * 0.12)
			+ sin(TIME * 0.21 + phase) * 0.18
			+ sin(TIME * 0.071 + phase * 0.37) * 0.12;
		float pass_index = floor(irregular_time);
		float pass_progress = fract(irregular_time);
		float pass_random_a = random_value(pass_index + rand * 19.31);
		float pass_random_b = random_value(pass_index * 1.73 + rand * 41.17);
		float pass_random_c = random_value(pass_index * 2.37 + rand * 73.91);
		float idle_fraction = mix(0.06, 0.38, pass_random_a);
		float reflection_active = step(idle_fraction, pass_progress);
		float travel_progress = clamp(
			(pass_progress - idle_fraction) / max(0.01, 1.0 - idle_fraction),
			0.0,
			1.0
		);
		travel_progress = travel_progress * travel_progress * (3.0 - 2.0 * travel_progress);
		float travel_direction = mix(-1.0, 1.0, step(0.32, pass_random_c));
		float pulse = 0.5 + 0.5 * sin(TIME * 1.65 + phase + sin(TIME * 0.37));

		// Bend the traveling reflection with overlapping waves. This keeps the
		// highlight organic instead of moving as a perfectly straight scan line.
		float wave_offset =
			sin(pixel.y * mix(0.12, 0.21, pass_random_b) + phase + pass_random_a * 5.0)
				* mix(2.4, 5.8, pass_random_c)
			+ sin(pixel.y * mix(0.055, 0.1, pass_random_c) - phase * 0.4 + pass_random_b * 4.0)
				* mix(1.2, 3.1, pass_random_a);
		float sweep_position = fract(
			(pixel.x + pixel.y * 0.62 + wave_offset) * 0.0095
			- travel_progress * travel_direction
			+ rand
			+ pass_random_b * 0.24
		);
		float sweep_distance = abs(sweep_position - 0.5);
		float reflection = (1.0 - smoothstep(0.0, 0.18, sweep_distance)) * reflection_active;
		float reflection_core = (1.0 - smoothstep(0.0, 0.04, sweep_distance)) * reflection_active;

		// A weaker counter-ripple stops each pass from looking identical.
		float ripple_offset = sin(pixel.x * 0.12 - irregular_time * 1.8 + phase) * 3.0;
		float ripple_position = fract(
			(pixel.x * 0.58 - pixel.y * 0.82 + ripple_offset) * 0.008
			+ irregular_time * 0.54
			+ rand * 0.37
		);
		float ripple = (1.0 - smoothstep(0.0, 0.1, abs(ripple_position - 0.5)))
			* 0.32 * reflection_active;
		float natural_flicker = 0.76 + 0.24 * sin(
			TIME * 2.1 + phase + sin(TIME * 0.61 + phase) * 0.8
		);
		float sheen = clamp(reflection + ripple, 0.0, 1.0) * natural_flicker;

		// Alpha differences around a pixel identify the silhouette and facet gaps.
		vec2 px = TEXTURE_PIXEL_SIZE;
		float nearby_alpha = min(
			min(texture(TEXTURE, UV + vec2(px.x, 0.0)).a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a),
			min(texture(TEXTURE, UV + vec2(0.0, px.y)).a, texture(TEXTURE, UV - vec2(0.0, px.y)).a)
		);
		float crystal_edge = clamp(tex.a - nearby_alpha, 0.0, 1.0);

		// Distort the sampled color by less than one pixel while the reflection
		// passes. Together with the brief opacity dip this resembles refraction.
		vec2 refraction_direction = vec2(
			sin(pixel.y * 0.21 + irregular_time * 2.0 + phase),
			cos(pixel.x * 0.16 - irregular_time * 1.4 + phase)
		);
		vec2 refraction_offset = refraction_direction * px * (0.35 + quality * 0.55) * reflection;
		vec3 refracted_color = texture(TEXTURE, UV + refraction_offset).rgb;

		float facet = 0.5
			+ 0.26 * sin(pixel.x * 0.39 - pixel.y * 0.28 + phase)
			+ 0.24 * sin(pixel.x * 0.14 + pixel.y * 0.37 - TIME * 0.32 + phase);
		vec3 crystal_sample = mix(tex.rgb, refracted_color, reflection * (0.12 + quality * 0.12));
		vec3 base = mix(crystal_sample, crystal_sample * gem_color.rgb, 0.08 + quality * 0.08);

		// Bright gem colors have less additive headroom. Preserve their painted
		// facets by darkening source shadow pixels while leaving highlights intact,
		// then reduce added glow according to the gem color's luminance.
		float gem_luminance = dot(gem_color.rgb, vec3(0.2126, 0.7152, 0.0722));
		float source_luminance = dot(tex.rgb, vec3(0.2126, 0.7152, 0.0722));
		float bright_color_guard = smoothstep(0.42, 0.82, gem_luminance);
		float shadow_detail = mix(0.76, 1.0, smoothstep(0.12, 0.78, source_luminance));
		base *= mix(1.0, shadow_detail, bright_color_guard);
		float effect_headroom = 1.0 - bright_color_guard * 0.52;

		base *= 0.96 + facet * (0.04 + quality * 0.05);
		base += gem_color.rgb * crystal_edge * (0.18 + quality * 0.28) * effect_headroom;
		float white_reflection_mix = mix(0.48, 0.27, bright_color_guard);
		vec3 reflected_light = mix(gem_color.rgb, vec3(0.9, 0.97, 1.0), white_reflection_mix);
		base += reflected_light * sheen * tex.a * (0.13 + quality * 0.3)
			* (0.72 + pulse * 0.28) * effect_headroom;
		base += vec3(1.0) * reflection_core * (0.055 + quality * 0.14) * effect_headroom;

		// The narrow reflective core becomes briefly translucent, revealing a
		// hint of the map underneath without making the whole gem look ghostly.
		float glass_transmission = reflection * (0.03 + quality * 0.03)
			+ reflection_core * (0.025 + quality * 0.04);
		float glass_alpha = tex.a * (1.0 - clamp(glass_transmission, 0.0, 0.14));
		COLOR = vec4(base, glass_alpha);
	}
}

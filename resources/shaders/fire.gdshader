// Copyright Nathanael C. Fritz 2024
// MIT License

shader_type canvas_item;
render_mode unshaded;

// Warping and blending textures, intended for seamless simplex/smooth noise.
uniform sampler2D flame1_texture : repeat_enable, filter_linear;
uniform sampler2D flame2_texture : repeat_enable, filter_linear;
uniform sampler2D flame3_texture : repeat_enable, filter_linear;
// Flame color ramp. Assign a GradientTexture1D.
uniform sampler2D color_gradient : source_color, repeat_disable, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float animation_speed : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float distortion_strength : hint_range(0.0, 0.2, 0.001) = 0.05;
uniform float brightness : hint_range(0.0, 8.0, 0.01) = 3.5;
uniform float cutoff : hint_range(0.0, 1.0, 0.01) = 0.12;
uniform float warp_cutoff : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float warp_opacity : hint_range(0.0, 1.0, 0.01) = 0.7;

vec4 blend_screen(vec4 base, vec4 blend) {
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
	float animation_time = TIME * animation_speed;
	// Differing scroll directions prevent the three noise layers from visibly
	// repeating together and give the center layer an upward flame motion.
	vec2 flame1_uv = vec2(UV.x - animation_time * 0.3, UV.y + animation_time * 0.1);
	vec2 flame2_uv = vec2(UV.x + animation_time * 0.3, UV.y + animation_time * 0.1);
	vec2 flame3_uv = vec2(UV.x, UV.y + animation_time * 0.8);

	float warp1 = texture(flame1_texture, flame1_uv * 2.1).r;
	float warp2 = texture(flame2_texture, flame2_uv * 2.1).r;
	vec2 warp = vec2(warp1 - warp2, 0.0) * distortion_strength;

	float flame1_sample = texture(flame1_texture, flame1_uv).r;
	float flame2_sample = texture(flame2_texture, flame2_uv).r;
	float flame3_sample = texture(flame3_texture, flame3_uv + warp).r;

	// Half oval rising from the bottom center of the ColorRect.
	vec2 shape_position = vec2(UV.x - 0.5, (UV.y - 1.0) * sqrt(0.2));
	float shape_fade = clamp(1.0 - length(shape_position) * 2.0, 0.0, 1.0);
	float flame = clamp(
		(flame1_sample + flame2_sample + flame3_sample * 1.5) / 3.5
			* shape_fade,
		0.0,
		1.0
	);

	float flame_alpha = step(cutoff, flame);
	float safe_warp_cutoff = max(warp_cutoff, 0.0001);
	float warp_alpha = smoothstep(0.0, safe_warp_cutoff, flame) * warp_opacity;
	vec3 screen_color = texture(
		screen_texture,
		SCREEN_UV + warp * warp_alpha
	).rgb;
	vec3 flame_color = texture(color_gradient, vec2(flame, 0.5)).rgb
		* flame * brightness;

	vec4 background = vec4(screen_color, 1.0);
	vec4 fire = blend_screen(background, vec4(flame_color, 1.0));
	COLOR = mix(background, fire, flame_alpha);
}

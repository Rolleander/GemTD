shader_type canvas_item;
render_mode unshaded;

// 2D adaptation of the spatial crystal shader. CanvasItem shaders have no
// ALBEDO or true SPECULAR output, so the specular response is simulated by an
// additive highlight shaped by the specular noise and gradient textures.

uniform sampler2D colorGradient1 : source_color, repeat_disable, filter_linear;
uniform sampler2D colorGradient2 : source_color, repeat_disable, filter_linear;
uniform sampler2D NoiseTexture_Alpha : repeat_enable, filter_linear;
uniform sampler2D NoiseTexture_Specular : repeat_enable, filter_linear;
uniform sampler2D gradientSpecular : source_color, repeat_disable, filter_linear;

uniform float effect_strength : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float gradient_mix : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float transparency_strength : hint_range(0.0, 1.0, 0.01) = 0.35;
uniform float minimum_alpha : hint_range(0.0, 1.0, 0.01) = 0.35;
uniform float specular_strength : hint_range(0.0, 3.0, 0.01) = 0.8;
uniform float specular_power : hint_range(1.0, 32.0, 0.5) = 8.0;
uniform float facet_scale : hint_range(1.0, 40.0, 0.5) = 12.0;
uniform float noise_scale : hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float animation_speed : hint_range(-3.0, 3.0, 0.01) = 0.08;
uniform vec2 noise_direction = vec2(0.13, -0.09);
uniform vec2 highlight_direction = vec2(0.7, -0.7);
uniform vec4 highlight_color : source_color = vec4(0.9, 0.97, 1.0, 1.0);

// Enable these when the Sprite2D uses a region from a texture atlas.
uniform bool use_region = false;
uniform vec2 region_position_px = vec2(0.0);
uniform vec2 region_size_px = vec2(1.0);

vec2 get_local_uv(vec2 texture_uv, vec2 texture_pixel_size) {
	if (!use_region) {
		return texture_uv;
	}
	vec2 region_min_uv = region_position_px * texture_pixel_size;
	vec2 region_size_uv = max(region_size_px * texture_pixel_size, vec2(0.000001));
	return (texture_uv - region_min_uv) / region_size_uv;
}

void fragment() {
	vec4 sprite = texture(TEXTURE, UV) * COLOR;
	if (sprite.a <= 0.001) {
		discard;
	}

	vec2 local_uv = clamp(get_local_uv(UV, TEXTURE_PIXEL_SIZE), vec2(0.0), vec2(1.0));
	vec2 animated_noise_uv = local_uv * noise_scale
		+ noise_direction * TIME * animation_speed;

	// World Y and Z from the spatial shader become the two available local 2D
	// axes. Sampling through the center row supports ordinary 1D gradient maps.
	vec3 color1 = texture(colorGradient1, vec2(1.0 - local_uv.y, 0.5)).rgb;
	vec3 color2 = texture(colorGradient2, vec2(local_uv.x, 0.5)).rgb;
	float facet_mix = clamp(
		gradient_mix
		+ sin((local_uv.x + local_uv.y) * facet_scale) * 0.12,
		0.0,
		1.0
	);
	vec3 gradient_color = mix(color1, color2, facet_mix);

	float source_luminance = dot(sprite.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 colored_crystal = gradient_color * mix(0.58, 1.28, source_luminance);
	vec3 base_color = mix(sprite.rgb, colored_crystal, effect_strength);

	float noise_alpha = texture(NoiseTexture_Alpha, animated_noise_uv).r;
	float crystal_alpha = mix(1.0, max(minimum_alpha, noise_alpha), transparency_strength);

	float noise_specular = texture(NoiseTexture_Specular, animated_noise_uv).r;
	float specular_gradient = texture(
		gradientSpecular,
		vec2(clamp(noise_specular, 0.0, 1.0), 0.5)
	).r;
	vec2 light_direction = normalize(highlight_direction + vec2(0.00001));
	float diagonal = dot(local_uv - vec2(0.5), light_direction);
	float moving_highlight = 0.5 + 0.5 * sin(
		diagonal * facet_scale * 2.0
		- TIME * animation_speed * 8.0
		+ noise_specular * 6.283185
	);
	float simulated_specular = pow(moving_highlight, specular_power)
		* specular_gradient
		* specular_strength;

	// Keep specular additive, matching a bright crystal reflection without
	// allowing the effect to darken the source sprite.
	vec3 final_color = base_color
		+ highlight_color.rgb * simulated_specular * highlight_color.a;
	COLOR = vec4(final_color, sprite.a * crystal_alpha);
}

shader_type canvas_item;
render_mode blend_add;

// for circles
uniform float amplitude: hint_range(0, 2, 0.01) = 2.0;
uniform float frequency: hint_range(0, 15, 0.01) = 12.69;
uniform float rippleRate : hint_range(0.5, 150.0, 0.1) = 9.2;


// for wave
uniform float waveAmplitude = 0.1;
uniform float waveFrequency = 4.0;
uniform float blendingAmount = 0.6;

uniform float effect_strength : hint_range(0.0, 1.0, 0.05) = 0.65;
uniform vec4 wave_color : source_color = vec4(0.55, 0.9, 1.0, 1.0);
uniform vec2 region_position_px = vec2(0.0);
uniform vec2 region_size_px = vec2(1.0);


// other
uniform sampler2D noise;



vec2 wave(vec2 uv, float time) {
    return vec2(
        uv.x + sin(uv.y * waveFrequency * 5.0 + time) * waveAmplitude,
        uv.y + sin(uv.x * waveFrequency + time) * waveAmplitude
    );
}

void fragment() {
	vec4 sprite_colour = texture(TEXTURE, UV) * COLOR;
	if (sprite_colour.a <= 0.001) {
		discard;
	}

	// Sprite2D region UVs point into the complete atlas. Convert them back to
	// zero-to-one coordinates so the ripple center is the center of this gem.
	vec2 region_min_uv = region_position_px * TEXTURE_PIXEL_SIZE;
	vec2 region_size_uv = max(region_size_px * TEXTURE_PIXEL_SIZE, vec2(0.000001));
	vec2 local_uv = (UV - region_min_uv) / region_size_uv;
	vec2 wave_uv = wave(local_uv, TIME);
	vec4 ns = texture(noise, wave_uv);
	
	vec2 motion = vec2(0.0, 1.0);
	float pi = 3.14159265358979323846;
	vec2 uv = local_uv * 2.0 - 1.0;

	float dist = length(uv);
	ns *= 1.4142135;
	dist += -0.1 * ns.x;
	float ripple = sin(dist * -frequency * pi + rippleRate * TIME) * amplitude / (dist + 1.0);


	float alphaScalar = (1.0 - min(dist, 1.0)) * ns.x * 2.5; 
	float wave_mask = 2.0 * ripple * alphaScalar * (ripple + ns.x * ns.y);
	wave_mask = max(wave_mask - ns.y * 0.45, 0.0);
	wave_mask = clamp(wave_mask * blendingAmount, 0.0, 1.0);

	// This shader is an additive overlay. The sprite alpha masks it to the gem,
	// while effect_strength controls how much of the bright ripple is applied.
	float final_alpha = sprite_colour.a * wave_mask * effect_strength * wave_color.a;
	COLOR = vec4(wave_color.rgb, final_alpha);
}

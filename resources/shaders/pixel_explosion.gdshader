shader_type canvas_item;

uniform sampler2D noise_tex_normal : repeat_enable, filter_nearest;
uniform sampler2D noise_tex : repeat_enable, filter_nearest;
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float strength : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float glow_strength : hint_range(0.0, 3.0, 0.01) = 0.85;

// Sprite2D regions use atlas UVs. These parameters keep pixelation, noise, and
// border clipping local to the selected enemy frame instead of the full atlas.
uniform bool use_region = false;
uniform vec2 region_position_px = vec2(0.0);
uniform vec2 region_size_px = vec2(1.0);

void fragment() {
	vec2 region_min_uv = vec2(0.0);
	vec2 region_size_uv = vec2(1.0);
	vec2 local_uv = UV;
	vec2 pixel_count = 1.0 / TEXTURE_PIXEL_SIZE;
	if (use_region) {
		region_min_uv = region_position_px * TEXTURE_PIXEL_SIZE;
		region_size_uv = max(region_size_px * TEXTURE_PIXEL_SIZE, vec2(0.000001));
		local_uv = (UV - region_min_uv) / region_size_uv;
		pixel_count = max(region_size_px, vec2(1.0));
	}

	vec2 direction = texture(noise_tex_normal, local_uv).xy;
	direction = direction * 2.0 - 1.0;
	direction *= strength * progress;

	vec2 pixelated_uv = floor(local_uv * pixel_count)
		/ max(pixel_count - vec2(1.0), vec2(1.0));
	float explosion_amount = smoothstep(0.0, 0.15, progress);
	vec2 exploded_uv = mix(local_uv, pixelated_uv - direction, explosion_amount);
	vec2 texture_uv = region_min_uv + exploded_uv * region_size_uv;
	vec4 tex = texture(TEXTURE, texture_uv) * COLOR;

	float dissolve_noise = texture(noise_tex, local_uv).r;
	float visible_mask = step(progress, dissolve_noise);
	float dissolve_edge = visible_mask
		* (1.0 - smoothstep(progress, progress + 0.12, dissolve_noise))
		* smoothstep(0.0, 0.04, progress);
	float death_glow = max(sin(progress * 3.14159265), 0.0)
		* visible_mask * glow_strength;
	tex.rgb += max(tex.rgb, vec3(0.12)) * death_glow;
	tex.rgb = mix(tex.rgb, vec3(1.0), dissolve_edge * 0.65);
	tex.rgb += vec3(1.0, 0.35, 0.08) * dissolve_edge * 0.35;
	tex.a *= visible_mask;

	// Remove samples displaced beyond the sprite frame so atlas neighbours and
	// stretched edge pixels cannot appear during the explosion.
	vec2 border_uv = exploded_uv * 2.0 - 1.0;
	float border = max(abs(border_uv.x), abs(border_uv.y));
	tex.a *= 1.0 - step(1.0, border);

	COLOR = tex;
}

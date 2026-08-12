// Fireworks shader
// Based on the ShaderToy shader by Martijn Steinrucken (BigWings), 2015:
// https://www.shadertoy.com/view/lscGRl

shader_type canvas_item;
render_mode unshaded, blend_add;

const int MAX_EXPLOSIONS = 12;
const int MAX_PARTICLES = 100;
const vec3 HASH_MOD = vec3(0.1031, 0.11369, 0.13787);

uniform int explosion_count : hint_range(1, 12, 1) = 8;
uniform int particle_count : hint_range(1, 100, 1) = 70;
uniform float speed : hint_range(0.0, 3.0, 0.01) = 0.5;
uniform float intensity : hint_range(0.0, 3.0, 0.01) = 1.0;
uniform float particle_size : hint_range(0.25, 3.0, 0.01) = 1.0;

vec3 hash31(float value) {
	vec3 p3 = fract(vec3(value) * HASH_MOD);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract(vec3(
		(p3.x + p3.y) * p3.z,
		(p3.x + p3.z) * p3.y,
		(p3.y + p3.z) * p3.x
	));
}

float hash12(vec2 value) {
	vec3 p3 = fract(vec3(value, 0.0) * HASH_MOD);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract((p3.x + p3.y) * p3.z);
}

float light_particle(vec2 uv, vec2 position, float size) {
	vec2 offset = uv - position;
	float size_squared = size * size;
	return size_squared / max(dot(offset, offset), 0.000001);
}

vec3 explosion(vec2 uv, vec2 origin, float seed, float time_progress) {
	vec3 result = vec3(0.0);
	vec3 explosion_noise = hash31(seed);
	vec3 base_color = explosion_noise;

	for (int i = 0; i < MAX_PARTICLES; i++) {
		if (i >= particle_count) {
			break;
		}
		vec3 particle_noise = hash31(float(i)) - 0.5;
		vec2 direction = particle_noise.xy;
		float direction_length = max(length(direction), 0.0001);
		direction /= direction_length;

		vec2 start_position = origin - vec2(0.0, time_progress * time_progress * 0.1);
		vec2 end_position = start_position + direction * particle_noise.z;
		float particle_time = 1.0 - pow(time_progress - 1.0, 2.0);
		vec2 position = mix(origin, end_position, particle_time);

		float size = mix(0.01, 0.005, smoothstep(0.0, 0.1, particle_time));
		size *= 1.0 - smoothstep(0.1, 1.0, particle_time);
		size *= particle_size;

		float sparkle = sin((particle_time + particle_noise.z) * 100.0) * 0.5 + 0.5;
		sparkle = pow(sparkle, pow(explosion_noise.x, 3.0) * 50.0) * 0.01;
		float sparkle_window = smoothstep(
			explosion_noise.x - explosion_noise.z,
			explosion_noise.x + explosion_noise.z,
			time_progress
		) * (1.0 - smoothstep(
			explosion_noise.y - explosion_noise.z,
			explosion_noise.y + explosion_noise.z,
			time_progress
		));
		size += sparkle * sparkle_window * particle_size;
		result += base_color * light_particle(uv, position, size);
	}

	return result;
}

void fragment() {
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect_ratio = viewport_size.x / max(viewport_size.y, 1.0);
	vec2 uv = UV;
	uv.x -= 0.5;
	uv.x *= aspect_ratio;

	float animation_time = TIME * speed;
	vec3 fireworks = vec3(0.0);

	for (int i = 0; i < MAX_EXPLOSIONS; i++) {
		if (i >= explosion_count) {
			break;
		}
		float explosion_time = animation_time + float(i) * 1234.45235;
		float explosion_id = floor(explosion_time);
		explosion_time = fract(explosion_time);

		vec2 origin = hash31(explosion_id).xy;
		origin.x -= 0.5;
		origin.x *= 1.6;
		fireworks += explosion(uv, origin, explosion_id, explosion_time);
	}

	float alpha = clamp(max(fireworks.r, max(fireworks.g, fireworks.b)), 0.0, 1.0);
	COLOR = vec4(fireworks * intensity, alpha);
}

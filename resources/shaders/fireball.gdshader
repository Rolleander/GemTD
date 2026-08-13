shader_type canvas_item;
render_mode blend_mix;

uniform float speed =   0.05;
uniform float strength = 20.0;
uniform float progress = 0.5;
uniform float alpha = 1;
uniform float offset = 0;

float snoise(vec3 uv, float res)
{
	const vec3 s = vec3(1e0, 1e2, 1e3);
	
	uv *= res;
	
	vec3 uv0 = floor(mod(uv, res))*s;
	vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
	
	vec3 f = fract(uv); f = f*f*(3.0-2.0*f);

	vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
		      	  uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);

	vec4 r = fract(sin(v*1e-1)*1e3);
	float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	r = fract(sin((v + uv1.z - uv0.z)*1e-1)*1e3);
	float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	return mix(r0, r1, f.z)*progress*1.7-1.;
}

void fragment() {

	vec2 p = -.5 + UV.xy ;
	
	float color = 3.0 - (3.*length(2.*p));
	
	vec3 coord = vec3(atan(p.x,p.y)/6.2832+.5, length(p)*.5, .5);
	
	for(int i = 1; i <= 5; i++)
	{
		float power = pow(2.0, float(i));
		float t = TIME + offset;
		color += (1.5 / power) * snoise(coord + vec3(0.,-t*speed*0.1, t*speed*0.2*0.1), power*floor(strength));
	}
	float flame_mask = smoothstep(-0.2, 0.22, color);
	float hot_core = smoothstep(0.45, 1.35, color);
	vec3 fire_color = mix(
		vec3(0.28, 0.015, 0.0),
		vec3(1.0, 0.16, 0.015),
		smoothstep(-0.1, 0.65, color)
	);
	fire_color = mix(fire_color, vec3(1.0, 0.72, 0.18), hot_core);

	// Keep a solid core and only fade the irregular outer edge. Deriving alpha
	// directly from the RGB intensity made the entire effect look additive.
	COLOR = vec4(fire_color, alpha * flame_mask);
}



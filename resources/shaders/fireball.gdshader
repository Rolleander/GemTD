shader_type canvas_item;

uniform float speed =   0.05;
uniform float strength = 20.0;
uniform float progress = 0.5;
uniform float alpha = 1;

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
		color += (1.5 / power) * snoise(coord + vec3(0.,-TIME*speed*0.1, TIME*speed*0.2*0.1), power*floor(strength));
	}
	COLOR = vec4( color, pow(max(color,0.),2.)*0.4, pow(max(color,0.),3.)*0.15 , 1.0);
	COLOR.a = min((COLOR.r + COLOR.g + COLOR.b),  alpha);
	//float r = distance(vec2(0.5,0.5), UV.xy) * 2.0;
	
	//COLOR.a = max(0, COLOR.a   * progress* (1.5-r));
}




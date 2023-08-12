shader_type canvas_item;

render_mode blend_add;

uniform sampler2D noise_img : repeat_enable;
uniform sampler2D noise_img2 : repeat_enable;
uniform vec3 glow_color : source_color;
uniform float rand; 
uniform float speed = 0.1;
uniform float energy = 0.3;

void vertex(){
	float scale = 1.0 +cos( TIME/2.0   + rand * 300.0) *0.2;
	VERTEX *=scale;
}

void fragment(){
	float u = UV.x;
	float v = UV.y;
	vec3 f1 = texture(noise_img2, vec2(u + speed *  TIME,v- rand)).rgb;
	vec3 f2 = texture(noise_img, vec2(u +rand ,v + speed  * TIME)).rgb;
	vec3 f3 = texture(noise_img2, vec2(u -rand ,v- speed *  TIME)).rgb;
	vec3 color = f1 * f2 * f3;
	color.rgb *= glow_color*1.0 + vec3(0.5);
	COLOR.rgb = color;
	COLOR.a = clamp(COLOR.a, 0.0, energy);
	
}
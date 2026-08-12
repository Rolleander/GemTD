shader_type canvas_item;
render_mode blend_add;
uniform sampler2D noise : repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec2 scroll = vec2(0.1,0.1);
const float dist_power = 0.3;

void fragment(){ 
vec4 noise_col = texture(noise, UV +scroll * TIME);	
///vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV+ dist_power * noise_col.rr );
vec4 color = texture(TEXTURE, UV);
//COLOR.rgb = n1 * n2 - screen_color.rgb;
float modu = COLOR.a / color.a;
COLOR = noise_col*0.7 + color * 0.6;
COLOR.a = color.a * modu;
}

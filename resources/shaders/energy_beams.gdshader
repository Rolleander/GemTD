/*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/energy-beams

This shader is under CC0 license. Feel free to use, improve and 
change this shader according to your needs and consider sharing 
the modified result to godotshaders.com.
*/

shader_type canvas_item;
render_mode blend_add; // Remove this if you want to use HDR glow instead (use "Glow" and "Outline Glow" sliders)

const int MAX_BEAMS = 10;
const int MAX_OCTAVES = 10;

uniform int beams : hint_range(1, 10, 1) = 2; // How many beams the energy field should have

uniform float energy = 3.0; // How much the beams will travel up and down
uniform int roughness : hint_range(1, 10, 1) = 3; // How compact the noise texture will be
uniform int frequency : hint_range(1, 30, 1) = 10; // Amount of "ripples" in the beams

uniform float speed = 1.0; // Animation speed
uniform float thickness : hint_range(0.0, 0.1) = 0.006; // Thickness of the main beam
uniform float outline_thickness : hint_range(0.0, 0.1) = 0.03; //Thickness of the outline color
uniform float beam_difference : hint_range(0.0, 1.0) = 0.0; // The thickness difference between the main beam and the other, if there are more than one beam. The closer to 1 the smaller the thickness difference.

uniform float glow : hint_range(0.0, 3.0) = 0.0; // Use together with WorldEnvironment's Glow feature
uniform float outline_glow : hint_range(0.0, 3.0) = 0.0;

uniform vec4 color : source_color = vec4(0.91, 1.0, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.5, 1.0, 0.96, 1.0);

uniform float progress : hint_range(0.0, 1.0) = 1.0;

uniform float y_offset : hint_range(-0.5, 0.5) = 0.0; // Position of the beam
uniform float fixed_edge_size : hint_range(0.0, 0.5) = 0.05; // How close to the edge should the beam be still before the animatino starts
uniform vec2 noise_scale = vec2(1.0); // If the object (for example the ColorRect or Sprite node) is compressed use this to compensate for the noise texture being compressed.

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv, float time) {
    float amp = 0.01 * energy * progress;
    float freq = float(frequency);
	float value = 0.0;
	
    for (int i = 0; i < MAX_OCTAVES; i++) {
		if (i >= roughness) {
			break;
		}
        value += amp * noise(freq * vec2(uv.x, uv.y + time));
        amp *= 0.5;
        freq *= 2.0;
    }
    return value;
}

vec4 bolt(vec2 uv, float time, float i)
{
	// Setup the beam locking to the edges.
	float edge_size = max(fixed_edge_size, 0.0001);
	float falloff = smoothstep(0.0, edge_size, uv.x)
		* smoothstep(0.0, edge_size, 1.0 - uv.x);
	
	// Use Fractal Brownian Motion to create a "cloud texture" and use Difference blend mode to make the beam
	float clouds = fbm((uv + vec2(i)) * noise_scale, time * speed) * falloff;
	float beam_center = uv.y - 0.5 + y_offset
		+ uv.y * falloff * 0.02 * energy * progress;
	float diff_clouds = abs(clouds - beam_center);
	
	// Create a new noise to mask the beams on low "progress" values. To make a "turn-off" effect more visually interesting.
	float clouds2 = fbm((uv * 2.0) * noise_scale, time) * 5.0;
	diff_clouds += smoothstep(0.0, 0.8, clouds2) * 0.1 * (1.0 - progress);
	
	// Set thickness of the beams. First beam is the Thickness size and all following beams are sized with beam_difference
	float thickness_divisor = min(i + beam_difference, 1.0) + 1.0 - beam_difference;
	float beam_threshold = 1.0 - thickness / max(thickness_divisor, 0.0001) * progress;
	float antialias_width = max(0.0001, 0.005 * progress);
	float beam = clamp(
		smoothstep(beam_threshold, beam_threshold + antialias_width, 1.0 - diff_clouds),
		0.0,
		1.0
	);
	
	//Set the beam outlines
	float outline = beam_threshold - outline_thickness * progress;
	float beam_outline = clamp(
		smoothstep(outline, outline + 0.04, 1.0 - diff_clouds),
		0.0,
		1.0
	);
	beam_outline = clamp(beam_outline - beam, 0.0, 1.0);
	
	// Merge the beam and the outline and return to the fragment function
	return beam * (color + vec4(vec3(glow), 0.0))
		+ beam_outline * (outline_color + vec4(vec3(outline_glow), 0.0));
}

void fragment()
{	
	vec4 beam = vec4(0.0);
	
	for (int i = 0; i < MAX_BEAMS; i++) {
		if (i >= beams) {
			break;
		}
		beam = max(beam, bolt(UV, TIME, float(i)));
	}
	
	COLOR = beam;
}

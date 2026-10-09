shader_type canvas_item;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time : hint_range(0.0, 100.0) = 0.0;

float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float glitch = intensity;
	
	// random glitch lines
	float line = rand(vec2(TIME * 10.0, UV.y * 20.0));
	float slice = 0.0;
	if (line > 0.92) {
		slice = (rand(vec2(UV.y, TIME)) - 0.5) * glitch * 0.3;
	}
	
	vec2 uv = UV;
	uv.x += slice;
	
	// base color - black transparent with RGB split bars
	vec3 col = vec3(0.0);
	
	// red bar
	if (rand(vec2(uv.y * 5.0, time)) > 0.95) {
		col.r = glitch;
	}
	// cyan bar
	if (rand(vec2(uv.y * 7.0, time + 1.0)) > 0.95) {
		col.g = glitch;
		col.b = glitch;
	}
	// white noise
	float noise = rand(uv * time) * glitch * 0.2;
	col += vec3(noise);
	
	// scanlines
	float scan = sin(uv.y * 400.0) * 0.1 * glitch;
	col -= scan;
	
	COLOR = vec4(col, glitch * 0.6);
}
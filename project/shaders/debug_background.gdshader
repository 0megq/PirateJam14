shader_type canvas_item;

uniform float cells = 8.0; // how many cells in checkerboard pattern
uniform float angle: hint_range(0, 1.57079632679) = 0.0; // repeats every PI / 2

void vertex() { // rotate UVs by angle
	UV *= mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

void fragment() { // assign color by even/odd checkerboard pattern
	bool cell = mod(floor(UV.x * cells) + floor(UV.y * cells), 2.0) == 0.0;
	COLOR = vec4(vec3(cell ? 0.5 : 0.3), 1.0);
}
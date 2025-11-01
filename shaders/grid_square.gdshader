shader_type spatial;
render_mode unshaded, depth_draw_always;

uniform vec4 base_color: source_color = vec4(1.0);
uniform vec4 line_color: source_color = vec4(1.0);
uniform float line_width = 0.1;

vec4 square(vec2 uv, float width)
{
	uv = uv * 2.0 - 1.0;

	vec2 abs_uv = abs(uv.xy);
	float square = step(width, max(abs_uv.x, abs_uv.y));
	return vec4(vec3(square), 1.0);
}

void fragment() {
	vec4 color = base_color;
	if (square(UV, 1.0 - (line_width * 2.0)).r > 0.0) {
		color = line_color;
	}
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
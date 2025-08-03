shader_type spatial;


uniform vec4 color1 : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float lines_scale = 10.0;
uniform float scroll_speed = 1.0;
uniform bool invert_scroll_direction = false;

void fragment() {
	vec2 scrolling_uv = UV;

	float time_input = TIME * scroll_speed;
	float time_offset = time_input - floor(time_input);

	if (invert_scroll_direction) {
		scrolling_uv.y -= time_offset;
	} else {
		scrolling_uv.y += time_offset;
	}

	float pattern_input = (scrolling_uv.x + scrolling_uv.y) * lines_scale;
	float pattern_value = pattern_input - floor(pattern_input);

	vec3 final_color;
	if (pattern_value < 0.5) {
		final_color = color1.rgb;
	} else {
		final_color = color2.rgb;
	}

	ALBEDO = final_color;
}
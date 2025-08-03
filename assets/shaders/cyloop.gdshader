shader_type spatial;

render_mode depth_draw_always;

uniform vec4 color1 : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float lines_scale = 10.0; // Higher values = more lines
uniform float scroll_speed = 1.0;
uniform bool invert_scroll_direction = false;

void fragment() {
	vec2 scrolling_uv = UV;

	// Apply vertical scrolling to the UV coordinates
	if (invert_scroll_direction) {
		scrolling_uv.y -= TIME * scroll_speed;
	} else {
		scrolling_uv.y += TIME * scroll_speed;
	}

	// Create a diagonal pattern by adding x and y, then scale it
	float pattern = (scrolling_uv.x + scrolling_uv.y) * lines_scale;

	// Use fract() to make the pattern repeat, creating saw-tooth waves
	// Use step() to turn the gradient into a hard 0 or 1 mask
	float mask = step(0.5, fract(pattern));

	// Mix the two colors based on the mask to create the final lines
	// mix(color_a, color_b, weight)
	vec3 final_color = mix(color1.rgb, color2.rgb, mask);

	ALBEDO = final_color;
}
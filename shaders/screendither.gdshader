shader_type canvas_item;

uniform float dot_size : hint_range(2.0, 64.0) = 8.0;
uniform float threshold : hint_range(0.0, 1.0) = 0.0;
uniform vec4 bg_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 pixel_pos = SCREEN_UV / SCREEN_PIXEL_SIZE;
	vec2 cell = floor(pixel_pos / dot_size);
	vec2 cell_center_uv = (cell + 0.5) * dot_size * SCREEN_PIXEL_SIZE;

	vec4 sampled = textureLod(screen_texture, cell_center_uv, 0.0);
	float lum = dot(sampled.rgb, vec3(0.299, 0.587, 0.114));

	float radius = max(lum - threshold, 0.0) / (1.0 - threshold) * 0.7071;
	vec2 cell_uv = fract(pixel_pos / dot_size) - 0.5;
	float dist = length(cell_uv);

	float blend = smoothstep(radius, radius - 0.05, dist);
	COLOR = mix(bg_color, sampled, blend);
}
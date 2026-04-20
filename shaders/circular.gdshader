shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	COLOR.a = 1.0 - round(distance(UV, vec2(0.5, 0.5)));
}

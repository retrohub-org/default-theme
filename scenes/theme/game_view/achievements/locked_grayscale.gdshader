// https://kidscancode.org/godot_recipes/3.x/shaders/greyscale/index.html
shader_type canvas_item;

uniform bool enable;
uniform vec4 modulate : source_color;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (enable) {
		float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
		COLOR.rgb = vec3(avg);
	}
	COLOR *= modulate;
}
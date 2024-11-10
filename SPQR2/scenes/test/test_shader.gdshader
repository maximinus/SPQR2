shader_type canvas_item;

uniform sampler2D image: source_color;
const float img_size = 50.0;

void fragment() {
	vec2 main_uv = UV / img_size;
	COLOR = texture(image, main_uv);
}

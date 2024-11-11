shader_type canvas_item;

const float WIDTH = 512.0;
const float BORDER_WIDTH = 0.03;

uniform sampler2D regions;
uniform sampler2D borders;
uniform sampler2D owners;
uniform sampler2D roads;
uniform vec4 highlight_mix: source_color;
uniform int selected_region;

void fragment() {
	vec4 final_color;
	vec4 region_pixel = texture(regions, UV);
	vec4 border_pixel = texture(borders, UV);
	bool highlight_region = false;
	
	if(region_pixel.a != 1.0) {
		final_color = texture(TEXTURE, UV);
	} else {
		// get the color of the region and convert
		float index = (round(region_pixel.b * 8.0) + round(region_pixel.r * 64.0));
		// calculate carefully
		float offset = 1.0 / 28.0;
		float index_offset = index * (1.0 / 14.0);
		float owner_ypos = offset + index_offset;
		
		highlight_region = selected_region == int(index);
		
		vec4 col1 = texture(owners, vec2(0.25, owner_ypos));
		vec4 col2 = texture(owners, vec2(0.75, owner_ypos));
		
		vec4 calculated_color;
		float xpos_stripe = (UV.x * WIDTH) + (UV.y * WIDTH);
		float stripe_value = sin(xpos_stripe) / 5.0;
		if(abs(stripe_value) < BORDER_WIDTH) {
			float lerp_val = ((stripe_value) + BORDER_WIDTH) / (BORDER_WIDTH * 2.0);
			final_color = mix(col1, col2, 1.0 - lerp_val);
		} else {
			if(stripe_value > 0.0) {
				final_color = col1;
			} else {
				final_color = col2;
			}
		}
	}
	// add roads and borders
	final_color = mix(final_color, border_pixel, border_pixel.a);
	vec4 road_pixel = texture(roads, UV);
	final_color = mix(final_color, road_pixel, road_pixel.a);
	if(highlight_region == true) {
		COLOR = mix(final_color, highlight_mix, highlight_mix.a);
	} else {
		COLOR = final_color;
	}
}

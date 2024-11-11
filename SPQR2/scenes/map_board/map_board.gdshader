shader_type spatial;

const float WIDTH = 512.0;
const float BORDER_WIDTH = 0.03;

// 4 textures: the map, it's roughness, the regions, the borders
// if you add source_color, we will get a color translation
uniform sampler2D image_map: source_color;
uniform sampler2D rough_map;
uniform sampler2D region_map;
uniform sampler2D border_map: source_color;
uniform sampler2D road_map: source_color;
// ownership of regions
uniform sampler2D map_owners: source_color;
uniform float roughness_scale = 1.2;
// color of pixel mouse is over now
uniform vec3 region_color;
uniform float total_regions;

void fragment() {
	// start by getting the color of the map regions
	vec4 roads_px = texture(road_map, UV);
	vec4 border_px = texture(border_map, UV);
	vec4 region_i = textureLod(region_map, UV, 0.0);
	vec3 calculated_color;
	vec3 final_color;
	if(region_i.a == 0.0) {
		// no region at this pixel, just draw the map
		final_color = mix(texture(image_map, UV).rgb, border_px.rgb, border_px.a);
	} else {
		// get the region index of this colour
		// how is this maths calculated?
		// the colors are created in gimp as integers in the rgb channels
		// (0, 255, 0) -> 0, (0, 255, 32) -> 1, (32, 255, 64) -> ((32 / 32) * 8) + ((64 / 32) * 2)
		// but our numbers are in floats so we would get 0/255, 255/255, 32/255
		// the resulting index needs to be a whole number in the range 0 -> number_of_regions - 1
		// we can ignore checking the range, we assume it is correct
		// to get to 32/255 -> 1, we multiply by 255, giving us 32, then divide by 32. but 255 / 32 is a constant
		// 256 is a much cleaner constant and accurate enough... 256 / 32 = 128 / 16 = 64 / 8 = 8
		
		float index = (round(region_i.b * 8.0) + round(region_i.r * 64.0));
		// calculate carefully
		float offset = 1.0 / (total_regions * 2.0);
		float index_offset = index * (1.0 / total_regions);
		float owner_ypos = offset + index_offset;
		
		// now we have to account for possible striped regions
		// in this case we modulate between UV(x, 0.5) and UV(x, 1.5)
		vec3 col1 = texture(map_owners, vec2(0.25, owner_ypos)).rgb;
		vec3 col2 = texture(map_owners, vec2(0.75, owner_ypos)).rgb;
		
		// now split as before
		float xpos_stripe = (UV.x * WIDTH) + (UV.y * WIDTH);
		float stripe_value = sin(xpos_stripe) / 5.0;
		if(abs(stripe_value) < BORDER_WIDTH) {
			float lerp_val = ((stripe_value) + BORDER_WIDTH) / (BORDER_WIDTH * 2.0);
			calculated_color = mix(col1, col2, 1.0 - lerp_val);
		} else {
			if(stripe_value > 0.0) {
				calculated_color = col1;
			} else {
				calculated_color = col2;
			}
		}
		//calculated_color = texture(map_owners, vec2(0.5, owner_ypos)).rgb;
		float tot = abs(region_i.r - region_color.r) + abs(region_i.g - region_color.g) + abs(region_i.b - region_color.b);
		// this value probably needs fine-tuning
		if(tot < 0.02) {
			// make a highlight, i.e. make the display brighter
			final_color = mix(calculated_color * 0.07, border_px.rgb, border_px.a);
		} else {
			// display the map
		final_color = mix(calculated_color, border_px.rgb, border_px.a);
		}
	}
	ALBEDO = mix(final_color, roads_px.rgb, roads_px.a);
	ROUGHNESS = texture(rough_map, UV).r / roughness_scale;
}

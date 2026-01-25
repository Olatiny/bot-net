shader_type canvas_item;

uniform int colors_to_replace : hint_range(0, 2, 1);

uniform vec4 source_color_1 : source_color;

uniform vec4 dest_color_1 : source_color;

uniform float tolerance_1 : hint_range(0, 1, 0.05);

uniform vec4 source_color_2 : source_color;

uniform vec4 dest_color_2 : source_color;

uniform float tolerance_2 : hint_range(0, 1, 0.05);


void fragment() {
	vec4 temp = COLOR;

	float dist_1 = distance(source_color_1.rgb, temp.rgb);
	float dist_2 = distance(source_color_2.rgb, temp.rgb);

	if (dist_1 < tolerance_1 && colors_to_replace > 0)
		COLOR.rgb = dest_color_1.rgb;

	if (dist_2 < tolerance_2 && colors_to_replace > 1)
		COLOR.rgb = dest_color_2.rgb;
}

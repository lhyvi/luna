shader_type canvas_item;

uniform float strength = 1.0;
uniform vec2 r_displacement = vec2(8.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-8.0, 0.0);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

const vec2 FIXED_SCREEN_PIXEL_SIZE = vec2(1.0/240.0, 1.0/180.0);

void fragment()
{
	vec4 color = vec4(0.0,0.0,0.0,texture(SCREEN_TEXTURE,SCREEN_UV).a);
	
	vec2 r = vec2(FIXED_SCREEN_PIXEL_SIZE * r_displacement);
	vec2 g = vec2(FIXED_SCREEN_PIXEL_SIZE * g_displacement);
	vec2 b = vec2(FIXED_SCREEN_PIXEL_SIZE * b_displacement);

	float lod = strength * strength * 2.0;
	color.r = texture(SCREEN_TEXTURE, SCREEN_UV + r * strength, lod).r;
	color.g = texture(SCREEN_TEXTURE, SCREEN_UV + g * strength, lod).g;
	color.b = texture(SCREEN_TEXTURE, SCREEN_UV + b * strength, lod).b;

	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

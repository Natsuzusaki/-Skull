shader_type canvas_item;

uniform float blur_size : hint_range(0.0, 10.0) = 2.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
	vec4 sum = vec4(0.0);
	vec2 uv = SCREEN_UV;

    // Sample in 9 directions
	sum += texture(SCREEN_TEXTURE, uv + vec2(-4.0, -4.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.05;
	sum += texture(SCREEN_TEXTURE, uv + vec2(-4.0,  4.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.05;
	sum += texture(SCREEN_TEXTURE, uv + vec2( 4.0, -4.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.05;
	sum += texture(SCREEN_TEXTURE, uv + vec2( 4.0,  4.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.05;

	sum += texture(SCREEN_TEXTURE, uv + vec2(-2.0, -2.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.09;
	sum += texture(SCREEN_TEXTURE, uv + vec2(-2.0,  2.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.09;
	sum += texture(SCREEN_TEXTURE, uv + vec2( 2.0, -2.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.09;
	sum += texture(SCREEN_TEXTURE, uv + vec2( 2.0,  2.0) * SCREEN_PIXEL_SIZE * blur_size) * 0.09;

	sum += texture(SCREEN_TEXTURE, uv) * 0.5;

	COLOR = sum;
}

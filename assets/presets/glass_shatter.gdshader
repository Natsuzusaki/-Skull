shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float time : hint_range(0.0, 2.0) = 0.0; // animate from 0→1
uniform sampler2D noise_tex : source_color; // crack mask (black background, white cracks)
uniform float intensity = 0.02; // how strong refraction is

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 crack = texture(noise_tex, uv);

    // Displace pixels outward from crack lines
    vec2 offset = (crack.rg - 0.5) * 2.0 * intensity * smoothstep(0.0, 1.0, time);
    COLOR = textureLod(SCREEN_TEXTURE, uv + offset, 0.0);
}

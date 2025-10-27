shader_type canvas_item;

uniform float speed = -1.0; // how fast it scrolls left

void fragment() {
    vec2 uv = UV;
    uv.x = fract(UV.x - TIME * speed); // scroll left and loop
    COLOR = texture(TEXTURE, uv);
}

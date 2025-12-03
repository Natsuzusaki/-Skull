shader_type canvas_item;

uniform float speed = -1.0;                 // how fast it scrolls left
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // node modulate fallback

void fragment() {
    vec2 uv = UV;
    uv.x = fract(uv.x - TIME * speed); // scroll left and loop
    vec4 tex = texture(TEXTURE, uv);
    COLOR = tex * tint_color;         // multiply texture by tint_color (alpha included)
}

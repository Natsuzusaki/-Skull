shader_type canvas_item;

uniform float amplitude = 0.05;
uniform float frequency = 12.0;
uniform float speed = 2.0;
uniform vec4 tint_color : source_color = vec4(0.4, 0.7, 1.0, 0.1); // color + base transparency
uniform float edge_strength = 1.5;  // how sharp the fade is near the edges

void fragment() {
    vec2 uv = UV;

    // Wavy distortion
    uv.x += sin(uv.y * frequency + TIME * speed) * amplitude;
    uv.y += cos(uv.x * frequency + TIME * speed * 0.7) * amplitude * 0.7;

    // Distance from center (0 = center, 1 = edge)
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);

    // Make edges stronger and center more transparent
    float fade = pow(dist * 2.0, edge_strength);
    fade = clamp(fade, 0.0, 1.0);

    // Final color (edges visible, center faded)
    vec4 color = tint_color;
    color.a *= fade;

    COLOR = color;
}

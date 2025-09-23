shader_type canvas_item;
render_mode unshaded;

uniform vec4 mist_color : source_color = vec4(0.9, 0.9, 0.95, 1.0); // Mist color + max alpha
uniform float mist_density : hint_range(0.0, 1.0) = 0.5; // Opacity strength
uniform float mist_height : hint_range(0.0, 1.0) = 0.5; // How high the mist rises (0=none, 1=full rect)
uniform float mist_speed = 0.05; // Scroll speed of mist
uniform float mist_scale = 3.0; // Size of noise

// Simple random
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453);
}

// Value noise
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f*f*(3.0-2.0*f);

    return mix(a, b, u.x) +
           (c - a)*u.y*(1.0 - u.x) +
           (d - b)*u.x*u.y;
}

// fractal Brownian motion
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 st = UV * mist_scale;

    // Scroll animation
    st.x += TIME * mist_speed;

    // Sample fractal noise
    float n = fbm(st);

    // Fade vertically (so mist hugs the ground)
    float vertical_mask = smoothstep(1.0, 1.0 - mist_height, UV.y);

    float alpha = n * mist_density * vertical_mask;

    COLOR = vec4(mist_color.rgb, alpha * mist_color.a);
}

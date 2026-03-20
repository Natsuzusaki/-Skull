shader_type canvas_item;

uniform float amplitude = 5.0; // height of movement
uniform float speed = 2.0;     // movement speed

void vertex() {
    VERTEX.y += sin(TIME * speed) * amplitude;
}
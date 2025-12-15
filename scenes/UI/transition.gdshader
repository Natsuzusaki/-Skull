shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;
uniform vec2 numberOftiles = vec2(15, 8.4375);
uniform vec2 pixelsPrTile = vec2(16,16);

void fragment() {
	vec2 positionInSquare = UV * numberOftiles;
	vec2 pixelPosition = round(positionInSquare * pixelsPrTile);
	vec2 frac = fract(pixelPosition / pixelsPrTile);
	vec2 direction = abs(frac - 0.5);

	if(direction.x + direction.y + UV.x + UV.y >= progress * 4.9){
		if(!reverse){
			discard;
		}
	}
	else if(reverse){
		discard;
	}
}


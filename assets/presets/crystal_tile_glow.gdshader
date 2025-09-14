shader_type canvas_item;
//
//uniform sampler2D tilemap_tex : source_color;
//
//void fragment() {
    //vec4 tex = texture(TEXTURE, UV);
    //COLOR = tex;
//
    //// Check neighbors for transparency (simplified example)
    //float glow = 0.0;
    //if (texture(TEXTURE, UV + vec2(1.0, 0.0)).a < 0.1) glow = 1.0;
    //if (texture(TEXTURE, UV + vec2(-1.0, 0.0)).a < 0.1) glow = 1.0;
    //if (texture(TEXTURE, UV + vec2(0.0, 1.0)).a < 0.1) glow = 1.0;
    //if (texture(TEXTURE, UV + vec2(0.0, -1.0)).a < 0.1) glow = 1.0;
//
    //// Add emissive color only at edges
    //if (glow > 0.0) {
        //COLOR.rgb += vec3(0.2, 0.6, 1.0) * glow;
    //}
//}

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float pixel_size : hint_range(1.0, 20.0, 1.0) = 1.0;
uniform float color_levels : hint_range(1.0, 500.0, 1.0) = 32.0;
uniform vec2 gamma = vec2(1.0, 1.0);

void fragment() {
    // 1. Get Screen UV (built-in for canvas_item)
    vec2 uv = SCREEN_UV;

    // 2. Pixelate
    if (pixel_size > 1.0) {
        vec2 size = vec2(textureSize(screen_texture, 0));
        uv = floor(uv * size / pixel_size) / (size / pixel_size);
    }

    vec4 color = texture(screen_texture, uv);

    // 3. Gamma & Grayscale logic
    color.rgb = pow(color.rgb, vec3(gamma.x));

    // Fixed your grayscale max() logic here
    float grayscale = max(color.r, max(color.g, color.b));

    float level = round(grayscale * color_levels) / color_levels;
    float adjustment = (grayscale > 0.0) ? (level / grayscale) : 0.0;

    color.rgb *= adjustment;
    color.rgb = pow(color.rgb, vec3(gamma.y));

    COLOR = vec4(color.rgb, 1.0);
}
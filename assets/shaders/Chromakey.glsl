vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 pixel = Texel(texture, texture_coords) * color;  // Obtém a cor do pixel

    // Verifica se o pixel é verde máximo (R e B próximos de 0 e G = 1.0)
    if (pixel.g > 0.99 && pixel.r < 0.1 && pixel.b < 0.1)
    {
        return vec4(0.0, 0.0, 0.0, 0.0);  // Transparente
    }

    return pixel;  // Mantém a cor original
}
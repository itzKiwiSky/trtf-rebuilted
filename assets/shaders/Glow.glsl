extern number min_luma;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
{
    vec4 c = Texel(texture, tc);
    number luma = dot(vec3(0.299, 0.587, 0.114), c.rgb);
    return c * step(min_luma, luma) * color;
}
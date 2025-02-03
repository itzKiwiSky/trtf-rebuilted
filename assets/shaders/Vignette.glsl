extern number radius;
extern number softness;
extern number opacity;
extern vec2 resolution;
extern vec4 color;

vec4 effect(vec4 c, Image tex, vec2 tc, vec2 _)
{
    number aspect = resolution.x / resolution.y;
    aspect = max(aspect, 1.0 / aspect); // use different aspect when in portrait mode
    number v = 1.0 - smoothstep(radius, radius-softness, length((tc - vec2(0.5)) * aspect));
    return mix(Texel(tex, tc), color, v*opacity);
}
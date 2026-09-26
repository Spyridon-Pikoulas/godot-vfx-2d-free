shader_type canvas_item;
// One-shot smoke puff: swells, rises and thins out.

#define VFX_CORE vec4(0.92, 0.92, 0.95, 1.0)
#define VFX_MID vec4(0.62, 0.62, 0.68, 0.95)
#define VFX_EDGE vec4(0.36, 0.36, 0.42, 0.7)
#include "vfx_common.gdshaderinc"

void fragment() {
	vec2 uv = vfx_uv(UV);
	vec2 p = vfx_p(uv);
	float t = progress;
	p.y += t * 0.35;
	float r = length(p);
	float radius = mix(0.4, 0.9, 1.0 - pow(1.0 - t, 2.0));
	float n = vfx_fbm(p * 2.5 + vec2(seed * 5.0, t * 1.5));
	float edge = r + (n - 0.5) * 0.6 * radius;
	float shape = smoothstep(radius, radius * 0.6, edge);
	float d = t * 1.1 - 0.2;
	float thin = smoothstep(d, d + 0.3, n);
	vec4 c = vfx_ramp((1.0 - edge / radius) * 0.8 + n * 0.4 - p.y * 0.15);
	c.a *= shape * thin;
	COLOR = vfx_finish(c, UV);
}

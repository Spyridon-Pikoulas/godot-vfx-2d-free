shader_type canvas_item;
// One-shot fireball: bursts out, cools to smoke and breaks apart.

#define VFX_CORE vec4(1.0, 0.97, 0.8, 1.0)
#define VFX_MID vec4(1.0, 0.5, 0.1, 1.0)
#define VFX_EDGE vec4(0.3, 0.09, 0.09, 0.85)
#include "vfx_common.gdshaderinc"

void fragment() {
	vec2 uv = vfx_uv(UV);
	vec2 p = vfx_p(uv);
	float t = progress;
	float r = length(p);
	float radius = mix(0.25, 0.92, 1.0 - pow(1.0 - t, 3.0));
	float n = vfx_fbm(p * 3.0 + seed * 7.0 - p / max(r, 0.001) * t * 1.5);
	float edge = r + (n - 0.5) * 0.55 * radius;
	float shape = smoothstep(radius, radius * 0.85, edge);
	// Breaks up from the rim inwards.
	float d = t * t * 1.7 - 0.2;
	float eaten = smoothstep(d, d + 0.15, n + 0.35 * (1.0 - edge / radius));
	float heat = (1.0 - edge / radius) * 2.2 * (1.0 - t) + n * 0.3 - t * 0.35;
	heat += smoothstep(0.15, 0.0, t) * 0.8;
	vec4 c = vfx_ramp(heat);
	c.a *= shape * eaten;
	COLOR = vfx_finish(c, UV);
}

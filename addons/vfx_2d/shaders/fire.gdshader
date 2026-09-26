shader_type canvas_item;
// Looping flame rising from the bottom of the rect.

#define VFX_CORE vec4(1.0, 0.95, 0.65, 1.0)
#define VFX_MID vec4(1.0, 0.45, 0.05, 1.0)
#define VFX_EDGE vec4(0.7, 0.08, 0.05, 0.0)
#include "vfx_common.gdshaderinc"

void fragment() {
	vec2 uv = vfx_uv(UV);
	float time = TIME * speed;
	float h = 1.0 - uv.y;
	float n = vfx_fbm(vec2(uv.x * 3.0 + seed, h * 2.5 - time * 2.0));
	float n2 = vfx_fbm(vec2(uv.x * 6.0 - seed, h * 4.0 - time * 3.2));
	float x = uv.x - 0.5 + (n - 0.5) * 0.35 * h;
	float width = 0.42 * (1.0 - h * 0.7);
	float body = 1.0 - abs(x) / width;
	float flame = body * 0.9 - h * 0.75 + (n2 - 0.5) * 0.9 * h + 0.2;
	float shape = smoothstep(0.0, 0.2, flame);
	vec4 c = vfx_ramp(flame * 1.6 + (1.0 - h) * 0.15);
	c.a = max(c.a, 0.85) * shape * smoothstep(0.0, 0.04, h + 0.02);
	COLOR = vfx_finish(c, UV);
}

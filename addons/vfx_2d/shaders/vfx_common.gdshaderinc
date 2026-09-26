// Shared by every VFX 2D shader. An effect defines VFX_CORE, VFX_MID and VFX_EDGE (its default
// colours) before including this.

uniform float progress : hint_range(0.0, 1.0) = 0.4;  // one-shots: 0 start, 1 gone
uniform float speed : hint_range(0.0, 4.0) = 1.0;     // loops
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float seed = 0.0;
uniform vec4 color_core : source_color = VFX_CORE;
uniform vec4 color_mid : source_color = VFX_MID;
uniform vec4 color_edge : source_color = VFX_EDGE;
uniform vec2 rect_size = vec2(128.0);                 // set by VFX2D; pixel_size is measured in it
uniform float pixel_size : hint_range(0.0, 16.0, 1.0) = 0.0;
uniform float color_steps : hint_range(0.0, 16.0, 1.0) = 0.0;

const float VFX_TAU = 6.2831853;

float vfx_hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vfx_hash1(float x) { return vfx_hash(vec2(x, x * 0.713 + 3.1)); }

// Integer hash for lattice points: a float hash of large coordinates rounds differently at each
// call site on some GPUs, which tears the noise into steps.
float vfx_hash_i(ivec2 i) {
	uvec2 q = uvec2(i) * uvec2(1597334673u, 3812015801u);
	uint n = (q.x ^ q.y) * 1597334673u;
	return float(n) * (1.0 / 4294967295.0);
}

float vfx_noise(vec2 p) {
	vec2 fl = floor(p);
	ivec2 i = ivec2(fl);
	vec2 f = p - fl;
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(vfx_hash_i(i), vfx_hash_i(i + ivec2(1, 0)), u.x),
			mix(vfx_hash_i(i + ivec2(0, 1)), vfx_hash_i(i + ivec2(1, 1)), u.x), u.y);
}

// 0..1, spread to cover the range.
float vfx_fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * vfx_noise(p);
		p = p * 2.03 + 17.0;
		a *= 0.5;
	}
	return clamp((v - 0.15) / 0.7, 0.0, 1.0);
}

float vfx_bayer2(vec2 a) {
	a = floor(a);
	return fract(dot(a, vec2(0.5, a.y * 0.75)));
}
float vfx_bayer4(vec2 a) { return vfx_bayer2(0.5 * a) * 0.25 + vfx_bayer2(a); }

// UV snapped to the centre of its pixel_size cell.
vec2 vfx_uv(vec2 uv) {
	if (pixel_size < 1.0) {
		return uv;
	}
	vec2 cells = max(floor(rect_size / pixel_size), vec2(1.0));
	return (floor(uv * cells) + 0.5) / cells;
}

// -1..1 across the height, x stretched by the aspect, so circles stay round.
vec2 vfx_p(vec2 uv) {
	vec2 p = uv * 2.0 - 1.0;
	p.x *= rect_size.x / rect_size.y;
	return p;
}

// One screen pixel, or one pixel_size block, in vfx_p units: keeps thin lines visible.
float vfx_px() {
	return 2.0 / rect_size.y * max(pixel_size, 1.0);
}

// heat 0 -> edge, 0.5 -> mid, 1 -> core; alpha comes from the colours too.
vec4 vfx_ramp(float heat) {
	heat = clamp(heat, 0.0, 1.0);
	return heat < 0.5 ? mix(color_edge, color_mid, heat * 2.0) : mix(color_mid, color_core, heat * 2.0 - 1.0);
}

// Colour steps, and in pixel mode an ordered-dither alpha so edges stay crisp.
vec4 vfx_finish(vec4 c, vec2 uv) {
	c.a = clamp(c.a * intensity, 0.0, 1.0);
	if (color_steps >= 1.0) {
		c.rgb = floor(c.rgb * color_steps + 0.5) / color_steps;
	}
	if (pixel_size >= 1.0) {
		vec2 cell = floor(uv * rect_size / pixel_size);
		c.a = step(vfx_bayer4(cell) * 0.8 + 0.1, c.a);
	}
	return c;
}

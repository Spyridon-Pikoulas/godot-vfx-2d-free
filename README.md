# VFX 2D Free

**4 animated 2D effects for Godot 4, free, one line of code each.** Every effect is a single shader
on a single node: no sprite sheets, no particle setup, sharp at any size.

```gdscript
VFX2D.spawn(self, "explosion", enemy.global_position)
VFX2D.spawn(self, "spark", hit_position, {color_mid = Color.CYAN})
```

### What's inside

- **explosion**, **smoke** and **spark**: one-shots that play once and clean up after themselves.
- **fire**: a loop that burns until you stop it.
- Three colours per effect, a random variation per spawn, size, duration, speed and intensity.
- **Pixel-art mode:** `VFX2D.default_pixel_size = 3` and the effects draw in crisp pixels with
  dithered edges.
- Drop a VFX2D node in a scene and it previews itself in the editor.

### Want more?

**[VFX 2D](https://heyheythere.itch.io/vfx-2d)** has all 16: shockwave, slash, sparkle, muzzle flash, dust, teleport,
lightning, beam, portal, magic circle, shield and orb on top of these four. Same node, same code:
install it over this one.

### Compatibility

- Godot **4.3 to 4.7**, tested on both ends.
- **Forward+, Mobile and Compatibility** renderers: desktop, mobile and web.
- GDScript only: no C#, no GDExtension.

### Install

Copy `addons/vfx_2d/` into your project. Open `demo/demo.tscn` to try the effects.

### License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/): use it in any game, commercial or not,
change it and share it, as long as you credit it. The credit line, for your game's credits:

`VFX 2D Free by heyheythere - https://heyheythere.itch.io/vfx-2d-free - CC BY 4.0`

*Made with AI assistance (code, text), tested in Godot 4.3 and 4.7 on every renderer.*

# VFX 2D

16 animated 2D effects for Godot 4.3+ (Forward+, Mobile, Compatibility). Each is one shader drawn
by one `VFX2D` node: no textures, no particles.

**The full pack:** **[VFX 2D](https://heyheythere.itch.io/vfx-2d)** has all 16: shockwave, slash, sparkle, muzzle flash, dust, teleport,
lightning, beam, portal, magic circle, shield and orb on top of these four. Same node, same code:
install it over this one.

## Play one

```gdscript
VFX2D.spawn(self, "explosion", enemy.global_position)          # plays, then frees itself
VFX2D.spawn(self, "slash", global_position, {scale = Vector2(-1, 1)})   # mirrored
VFX2D.spawn_between(self, "beam", $Gun.global_position, target.global_position)
var aura := VFX2D.spawn(player, "shield", player.global_position)
aura.stop()                                                     # loops play until stopped
await VFX2D.spawn(self, "teleport", pos).finished
```

Or add a VFX2D node to a scene, pick `effect`, and call `play()` (on by default through
`autoplay`). It previews in the editor, and its material holds the uniforms.

## Effects

`VFX2D.effects()` lists them all.

- One-shots: explosion, smoke, shockwave, spark, slash, sparkle, muzzle, dust, teleport
- Loops: lightning, beam, fire, portal, magic_circle, shield, orb

Lightning, beam and muzzle point along +x from the node; fire, dust and teleport stand on it; the
rest are centred on it.

## Options

Options go to `spawn()` or `set_option()`. A key that names a property of the node sets it, any
other key sets the shader uniform.

| option | | |
|---|---|---|
| `size` | node | rect in pixels, default per effect |
| `duration` | node | seconds for a one-shot; 0 loops it |
| `pixel_size` | node | pixel-art mode: size of a pixel; -1 follows `VFX2D.default_pixel_size` |
| `free_when_done` | node | false hides the node instead, ready to `play()` again |
| `scale`, `rotation`, `z_index`... | node | any Node2D property |
| `color_core`, `color_mid`, `color_edge` | shader | hottest to coolest; the edge alpha fades it out |
| `intensity` | shader | overall opacity, 0..2 |
| `speed` | shader | loop speed |
| `seed` | shader | variation; `spawn()` picks a random one |
| `color_steps` | shader | posterize to N levels per channel |
| `progress` | shader | one-shots: 0..1, driven by the node |

## Pixel art

```gdscript
VFX2D.default_pixel_size = 3   # once, before spawning
```

Effects then draw in 3x3 pixel blocks with dithered, hard edges. Combine with `color_steps` for a
limited palette.

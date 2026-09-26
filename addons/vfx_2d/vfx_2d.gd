@tool
class_name VFX2D
extends Node2D
## A 2D effect drawn by a shader into a rect: no textures, no particles, one node.
##
##     VFX2D.spawn(self, "explosion", enemy.global_position)
##     VFX2D.spawn_between(self, "lightning", $Wand.global_position, target.global_position)
##     var shield := VFX2D.spawn(player, "shield", player.global_position, {color_mid = Color.GOLD})
##     shield.stop()   # loops play until stopped; one-shots free themselves
##
## Options set a property of the node (size, duration, pixel_size, free_when_done...) or else a
## uniform of the shader (color_core, color_mid, color_edge, intensity, speed, seed, color_steps).
## In the editor the node previews itself, and the uniforms are in its material.

signal finished

const SHADERS := "res://addons/vfx_2d/shaders/%s.gdshader"
## size in pixels; duration in seconds, 0 = loops until stop(); pivot as a fraction of size.
const EFFECTS := {
	"explosion": {"size": Vector2(128, 128), "duration": 0.8},
	"smoke": {"size": Vector2(128, 128), "duration": 1.2},
	"shockwave": {"size": Vector2(160, 160), "duration": 0.5},
	"spark": {"size": Vector2(96, 96), "duration": 0.3},
	"slash": {"size": Vector2(128, 128), "duration": 0.35},
	"sparkle": {"size": Vector2(96, 128), "duration": 1.0},
	"muzzle": {"size": Vector2(64, 32), "duration": 0.15, "pivot": Vector2(0.0, 0.5)},
	"dust": {"size": Vector2(160, 64), "duration": 0.6, "pivot": Vector2(0.5, 1.0)},
	"teleport": {"size": Vector2(64, 160), "duration": 0.8, "pivot": Vector2(0.5, 1.0)},
	"lightning": {"size": Vector2(256, 64), "duration": 0.0, "pivot": Vector2(0.0, 0.5)},
	"beam": {"size": Vector2(256, 48), "duration": 0.0, "pivot": Vector2(0.0, 0.5)},
	"fire": {"size": Vector2(64, 128), "duration": 0.0, "pivot": Vector2(0.5, 1.0)},
	"portal": {"size": Vector2(128, 128), "duration": 0.0},
	"magic_circle": {"size": Vector2(160, 160), "duration": 0.0},
	"shield": {"size": Vector2(128, 128), "duration": 0.0},
	"orb": {"size": Vector2(96, 96), "duration": 0.0},
}

## Chunky pixels for every VFX2D whose pixel_size is -1: set once, before any spawn, for a
## pixel-art game.
static var default_pixel_size := 0

@export_enum("explosion", "smoke", "shockwave", "spark", "slash", "sparkle", "muzzle", "dust",
		"teleport", "lightning", "beam", "fire", "portal", "magic_circle", "shield", "orb")
var effect := "explosion":
	set(v):
		effect = v
		_setup()
## Zero uses the effect's size.
@export var size := Vector2.ZERO:
	set(v):
		size = v
		_sync()
## -1 uses the effect's duration; 0 loops until stop().
@export var duration := -1.0
## Size of a pixel in pixels, 0 smooth; -1 follows VFX2D.default_pixel_size.
@export_range(-1, 16, 1) var pixel_size := -1:
	set(v):
		pixel_size = v
		_sync()
@export var autoplay := true
@export var free_when_done := true

var elapsed := 0.0
var playing := false
var _fading: Tween


## The effects whose shader is installed.
static func effects() -> PackedStringArray:
	return PackedStringArray(EFFECTS.keys().filter(func(e: String) -> bool:
		return ResourceLoader.exists(SHADERS % e)))


## Adds an effect to `parent` at the global position `at` and plays it.
static func spawn(parent: Node, name: String, at: Vector2, options := {}) -> VFX2D:
	var v := VFX2D.new()
	v.effect = name
	v.set_param(&"seed", randf() * 10.0)
	for key in options:
		v.set_option(key, options[key])
	parent.add_child(v)
	v.global_position = at
	return v


## Stretches an effect from `from` to `to` (global positions): lightning, beam, muzzle.
static func spawn_between(parent: Node, name: String, from: Vector2, to: Vector2,
		options := {}) -> VFX2D:
	var v := spawn(parent, name, from, options)
	v.size = Vector2(from.distance_to(to), v.get_size().y)
	v.global_rotation = (to - from).angle()
	return v


func set_option(key: StringName, value: Variant) -> void:
	if key in self:
		set(key, value)
	else:
		set_param(key, value)


func set_param(uniform: StringName, value: Variant) -> void:
	(material as ShaderMaterial).set_shader_parameter(uniform, value)


func get_param(uniform: StringName) -> Variant:
	return (material as ShaderMaterial).get_shader_parameter(uniform)


func get_size() -> Vector2:
	return size if size != Vector2.ZERO else _spec()["size"]


func get_duration() -> float:
	return duration if duration >= 0.0 else _spec()["duration"]


func is_loop() -> bool:
	return get_duration() <= 0.0


## Starts over: a one-shot from progress 0, a loop at full strength.
func play() -> void:
	if _fading:
		_fading.kill()
		_fading = null
		set_param(&"intensity", 1.0)
	elapsed = 0.0
	playing = true
	set_param(&"progress", 0.0)
	show()


## Fades out over `fade` seconds, then finishes like a one-shot does.
func stop(fade := 0.25) -> void:
	if _fading or not is_inside_tree():
		return
	var from: Variant = get_param(&"intensity")
	_fading = create_tween()
	_fading.tween_method(func(v: float) -> void: set_param(&"intensity", v),
			1.0 if from == null else from, 0.0, fade)
	_fading.finished.connect(_finish)


func _init() -> void:
	_setup()


func _ready() -> void:
	if autoplay or Engine.is_editor_hint():
		play()


func _process(delta: float) -> void:
	if not playing or is_loop():
		return
	elapsed += delta
	var d := get_duration()
	if Engine.is_editor_hint():
		set_param(&"progress", clampf(fmod(elapsed, d + 0.4) / d, 0.0, 1.0))
		return
	set_param(&"progress", clampf(elapsed / d, 0.0, 1.0))
	if elapsed >= d:
		_finish()


func _finish() -> void:
	playing = false
	_fading = null
	finished.emit()
	if free_when_done:
		queue_free()
	else:
		hide()


func _spec() -> Dictionary:
	return EFFECTS.get(effect, EFFECTS["explosion"])


func _setup() -> void:
	if effect not in EFFECTS or not ResourceLoader.exists(SHADERS % effect):
		push_error("VFX2D: unknown effect %s, pick one of %s" % [effect, effects()])
		return
	var shader: Shader = load(SHADERS % effect)
	if not (material is ShaderMaterial and material.shader == shader):
		var m := ShaderMaterial.new()
		m.shader = shader
		m.resource_local_to_scene = true
		material = m
	_sync()


func _sync() -> void:
	if not material is ShaderMaterial:
		return
	set_param(&"rect_size", get_size())
	set_param(&"pixel_size", float(pixel_size if pixel_size >= 0 else default_pixel_size))
	queue_redraw()


func _draw() -> void:
	var s := get_size()
	draw_rect(Rect2(-s * _spec().get("pivot", Vector2(0.5, 0.5)), s), Color.WHITE)

extends Node2D
## Pick an effect, click the stage to play it. Beams, lightning and muzzle flashes fire from the
## caster to the click. Right click stops the loops.

const CASTER := Vector2(330, 560)

var chosen := "explosion"
var loops: Array[VFX2D] = []
var buttons := {}


func _ready() -> void:
	var panel := VBoxContainer.new()
	panel.position = Vector2(16, 16)
	panel.add_theme_constant_override("separation", 2)
	add_child(panel)
	var group := ButtonGroup.new()
	for name in VFX2D.effects():
		var b := Button.new()
		b.text = name
		b.toggle_mode = true
		b.button_group = group
		b.custom_minimum_size = Vector2(170, 0)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(func() -> void: chosen = name)
		panel.add_child(b)
		buttons[name] = b
	buttons[chosen].button_pressed = true
	var pixel := CheckBox.new()
	pixel.text = "pixel art"
	pixel.toggled.connect(func(on: bool) -> void: VFX2D.default_pixel_size = 3 if on else 0)
	panel.add_child(pixel)
	var hint := Label.new()
	hint.text = "Click to play the effect. Right click stops the loops."
	hint.position = Vector2(230, 16)
	hint.add_theme_color_override("font_color", Color(0.75, 0.78, 0.9))
	add_child(hint)
	for loop: Array in [["magic_circle", Vector2(760, 330), {scale = Vector2(1.6, 1.6)}],
			["fire", Vector2(560, 600), {}], ["portal", Vector2(1080, 520), {}],
			["shield", CASTER + Vector2(0, -20), {size = Vector2(96, 96)}]]:
		if loop[0] in VFX2D.effects():
			loops.append(VFX2D.spawn(self, loop[0], loop[1], loop[2]))


func _unhandled_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click == null or not click.pressed:
		return
	if click.button_index == MOUSE_BUTTON_RIGHT:
		for v in loops:
			if is_instance_valid(v):
				v.stop()
		loops.clear()
	elif click.button_index == MOUSE_BUTTON_LEFT:
		_play(chosen, click.position)


func _play(name: String, at: Vector2) -> void:
	if name in ["lightning", "beam", "muzzle"]:
		var v := VFX2D.spawn_between(self, name, CASTER + Vector2(0, -20), at)
		if v.is_loop():
			get_tree().create_timer(0.6).timeout.connect(v.stop)
		return
	var v := VFX2D.spawn(self, name, at)
	if v.is_loop():
		loops.append(v)


func _draw() -> void:
	draw_rect(get_viewport_rect(), Color(0.06, 0.06, 0.1))
	draw_rect(Rect2(210, 600, 1070, 120), Color(0.1, 0.09, 0.15))
	# The caster: a hooded figure in flat shapes.
	draw_colored_polygon(PackedVector2Array([CASTER + Vector2(-18, 40), CASTER + Vector2(0, -38),
		CASTER + Vector2(18, 40)]), Color(0.35, 0.3, 0.6))
	draw_circle(CASTER + Vector2(0, -26), 11, Color(0.85, 0.75, 0.6))
	draw_colored_polygon(PackedVector2Array([CASTER + Vector2(-14, -24), CASTER + Vector2(0, -60),
		CASTER + Vector2(14, -24)]), Color(0.3, 0.25, 0.55))

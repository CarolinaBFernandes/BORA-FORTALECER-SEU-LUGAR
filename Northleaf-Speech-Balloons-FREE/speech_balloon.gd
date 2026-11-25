## SpeechBalloon: a pixel dialogue bubble that sizes itself to its text and points its tail at the speaker.
##   var b := SpeechBalloon.new(); b.style = "shout"; b.palette = "light"; npc.add_child(b)
##   b.position = Vector2(0, -24)          # the tail tip sits exactly on the node position (above the head)
##   b.say("Get down!")                     # types the text, then shows the bouncing continue arrow
##   b.finished_typing / b.skip() / b.close()
## Styles: speech, shout, thought, whisper, box.  Palettes: light, dark, parchment.
class_name SpeechBalloon
extends Node2D

signal finished_typing

@export var style := "speech"
@export var palette := "light"
@export var max_width := 120.0        # text wraps beyond this (pixels)
@export var chars_per_second := 40.0  # 0 = show the text at once
@export var font_size := 8
@export var root_dir := "res://Northleaf-Speech-Balloons-FREE"

var _panel: NinePatchRect
var _label: Label
var _tail: Sprite2D
var _arrow: Sprite2D
var _shown := 0.0
var _typing := false
var _t := 0.0

func _ready() -> void:
	_panel = NinePatchRect.new()
	_panel.texture = load("%s/balloons/%s_%s_9slice.png" % [root_dir, style, palette])
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		_panel.set_patch_margin(side, 8)
	_panel.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE   # edge patterns repeat cleanly
	_panel.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	add_child(_panel)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", Color("ecedf6") if palette == "dark" else Color("1b1b26") if palette == "light" else Color("3d2a1a"))
	_panel.add_child(_label)
	if style != "box":
		_tail = Sprite2D.new()
		_tail.texture = load("%s/tails/%s_%s_tail_down.png" % [root_dir, style, palette])
		_tail.centered = false
		add_child(_tail)
	_arrow = Sprite2D.new()
	_arrow.texture = load("%s/indicators/continue_arrow_%s_8x8_strip4.png" % [root_dir, palette])
	_arrow.hframes = 4
	_arrow.centered = false
	_arrow.visible = false
	_panel.add_child(_arrow)
	visible = false

func say(text: String) -> void:
	visible = true
	_label.text = text
	# measure: wrap at max_width, then shrink to the text
	var font := _label.get_theme_font("font")
	var one_line := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var inner_w: float = min(one_line, max_width) + 2.0
	_label.size = Vector2(inner_w, 0)
	_label.custom_minimum_size = Vector2(inner_w, 0)
	_label.visible_characters = -1
	var inner_h: float = _label.get_minimum_size().y
	var pad := Vector2(9, 7)
	var size := Vector2(inner_w, inner_h) + pad * 2 + Vector2(6, 0)   # room for the continue arrow
	size = size.snapped(Vector2(8, 8)).max(Vector2(24, 24))           # multiples of 8 keep the tiled edges whole
	_panel.size = size
	_label.position = pad
	# tail tip on our origin, balloon above it
	var tail_h := 11
	_panel.position = Vector2(-round(size.x * 0.1), -size.y - tail_h + 2)
	if _tail:
		_tail.position = Vector2(-7, -tail_h)
	_arrow.position = Vector2(size.x - 13, size.y - 12)
	_arrow.visible = false
	_shown = 0.0
	_typing = chars_per_second > 0.0
	_label.visible_characters = 0 if _typing else -1
	if not _typing:
		_done()

func skip() -> void:
	if _typing:
		_label.visible_characters = -1
		_done()

func close() -> void:
	visible = false
	_typing = false

func _done() -> void:
	_typing = false
	_arrow.visible = true
	finished_typing.emit()

func _process(delta: float) -> void:
	_t += delta
	if _arrow.visible:
		_arrow.frame = int(_t * 6.0) % 4
	if _typing:
		_shown += chars_per_second * delta
		_label.visible_characters = int(_shown)
		if _shown >= _label.get_total_character_count():
			_label.visible_characters = -1
			_done()

func balloon_rect() -> Rect2:
	return Rect2(_panel.position, _panel.size)

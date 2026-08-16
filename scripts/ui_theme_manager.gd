extends RefCounted
class_name AshenrootUITheme

const UI_ROOT := "res://assets/ui"

const COLOR_BG_DARK := Color("0b0e12")
const COLOR_BG_MID := Color("141a1e")
const COLOR_BG_LIGHT := Color("20272a")
const COLOR_BORDER := Color("71837b")
const COLOR_BORDER_DIM := Color("4b5855")
const COLOR_TEXT := Color("ddd5bc")
const COLOR_TEXT_DIM := Color("9c9a89")
const COLOR_ACTIVE := Color("82c7b1")
const COLOR_RARE := Color("b79cff")
const COLOR_WARNING := Color("db8a55")
const COLOR_DANGER := Color("c95d5d")

var regular_font: Font
var bold_font: Font
var textures: Dictionary = {}


func setup() -> void:
	regular_font = _load_font("%s/fonts/DejaVuSansMono.ttf" % UI_ROOT)
	bold_font = _load_font("%s/fonts/DejaVuSansMono-Bold.ttf" % UI_ROOT)
	for asset_name in [
		"panel_main_9slice",
		"panel_dark_9slice",
		"panel_active_9slice",
		"panel_rare_9slice",
		"panel_danger_9slice",
		"button_normal",
		"button_hover",
		"button_pressed",
		"button_disabled",
		"button_rare",
		"button_danger",
		"slot_empty",
		"slot_occupied",
		"slot_selected",
		"slot_unavailable",
		"health_bar_frame",
		"health_bar_fill",
		"stamina_bar_frame",
		"stamina_bar_fill",
		"mana_bar_frame",
		"mana_bar_fill"
	]:
		textures[asset_name] = _load_texture("%s/panels/%s.png" % [UI_ROOT, asset_name])


func panel_style(kind := "main", content_margin := 10.0) -> StyleBox:
	var texture_name := "panel_main_9slice"
	if kind == "dark":
		texture_name = "panel_dark_9slice"
	elif kind == "active":
		texture_name = "panel_active_9slice"
	elif kind == "rare":
		texture_name = "panel_rare_9slice"
	elif kind == "danger":
		texture_name = "panel_danger_9slice"
	return _texture_style(texture_name, 4.0, content_margin)


func apply_button(button: Button, variant := "normal") -> void:
	var normal_name := "button_rare" if variant == "rare" else "button_normal"
	if variant == "danger":
		normal_name = "button_danger"
	button.add_theme_stylebox_override("normal", _texture_style(normal_name, 4.0, 6.0))
	button.add_theme_stylebox_override("hover", _texture_style("button_hover", 4.0, 6.0))
	button.add_theme_stylebox_override("pressed", _texture_style("button_pressed", 4.0, 6.0))
	button.add_theme_stylebox_override("disabled", _texture_style("button_disabled", 4.0, 6.0))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", COLOR_ACTIVE)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT_DIM)
	if bold_font != null:
		button.add_theme_font_override("font", bold_font)


func apply_line_edit(line_edit: LineEdit) -> void:
	line_edit.add_theme_stylebox_override("normal", panel_style("dark", 6.0))
	line_edit.add_theme_stylebox_override("focus", panel_style("active", 6.0))
	line_edit.add_theme_stylebox_override("read_only", panel_style("dark", 6.0))
	line_edit.add_theme_color_override("font_color", COLOR_TEXT)
	line_edit.add_theme_color_override("font_placeholder_color", COLOR_TEXT_DIM)
	line_edit.add_theme_color_override("caret_color", COLOR_ACTIVE)
	line_edit.add_theme_color_override("selection_color", Color(COLOR_ACTIVE, 0.35))
	if regular_font != null:
		line_edit.add_theme_font_override("font", regular_font)


func apply_slot(button: Button, selected: bool, occupied := true, unavailable := false) -> void:
	var normal_name := "slot_selected" if selected else ("slot_occupied" if occupied else "slot_empty")
	if unavailable:
		normal_name = "slot_unavailable"
	button.add_theme_stylebox_override("normal", _texture_style(normal_name, 4.0, 4.0))
	button.add_theme_stylebox_override("hover", _texture_style("slot_selected", 4.0, 4.0))
	button.add_theme_stylebox_override("pressed", _texture_style("slot_occupied", 4.0, 4.0))
	var disabled_name := "slot_unavailable" if unavailable else ("slot_occupied" if occupied else "slot_empty")
	button.add_theme_stylebox_override("disabled", _texture_style(disabled_name, 4.0, 4.0))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	if regular_font != null:
		button.add_theme_font_override("font", regular_font)


func apply_progress_bar(bar: ProgressBar, kind := "health", fallback_fill := Color("b23838")) -> void:
	var frame_name := "%s_bar_frame" % kind
	var fill_name := "%s_bar_fill" % kind
	if textures.get(frame_name) != null and textures.get(fill_name) != null:
		bar.add_theme_stylebox_override("background", _texture_style(frame_name, 3.0, 0.0))
		bar.add_theme_stylebox_override("fill", _texture_style(fill_name, 2.0, 0.0))
		return
	var background := StyleBoxFlat.new()
	background.bg_color = COLOR_BG_DARK
	background.border_color = COLOR_BORDER_DIM
	background.set_border_width_all(1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fallback_fill
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)


func apply_font_tree(root: Node) -> void:
	if root is Control:
		var control := root as Control
		if regular_font != null:
			control.add_theme_font_override("font", regular_font)
	for child in root.get_children():
		apply_font_tree(child)


func _texture_style(texture_name: String, patch_margin: float, content_margin: float) -> StyleBox:
	var texture: Texture2D = textures.get(texture_name)
	if texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = COLOR_BG_MID
		fallback.border_color = COLOR_BORDER_DIM
		fallback.set_border_width_all(1)
		fallback.content_margin_left = content_margin
		fallback.content_margin_top = content_margin
		fallback.content_margin_right = content_margin
		fallback.content_margin_bottom = content_margin
		return fallback
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = patch_margin
	style.texture_margin_top = patch_margin
	style.texture_margin_right = patch_margin
	style.texture_margin_bottom = patch_margin
	style.content_margin_left = content_margin
	style.content_margin_top = content_margin
	style.content_margin_right = content_margin
	style.content_margin_bottom = content_margin
	return style


func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as Texture2D


func _load_font(path: String) -> Font:
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as Font

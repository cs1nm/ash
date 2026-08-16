extends CanvasLayer
class_name PauseMenuView

signal resume_requested
signal save_requested
signal quit_requested
signal ui_scale_changed(scale: float)

var ui_theme: AshenrootUITheme
var overlay: ColorRect
var menu_panel: PanelContainer
var settings_panel: PanelContainer
var status_label: Label
var fullscreen_toggle: CheckButton
var ui_scale_selector: OptionButton
var is_open := false
var ui_scale := 1.0

const SETTINGS_PATH := "user://ui_settings.cfg"


func setup(theme: AshenrootUITheme) -> void:
	ui_theme = theme
	_load_settings()
	name = "PauseMenu"
	layer = 300
	process_mode = Node.PROCESS_MODE_ALWAYS

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color("05080b", 0.78)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	menu_panel = _make_panel(Vector2(390, 350))
	overlay.add_child(menu_panel)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 10)
	menu_panel.add_child(menu)

	menu.add_child(_make_title("ASHENROOT"))
	var subtitle := Label.new()
	subtitle.text = "GAME PAUSED"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", AshenrootUITheme.COLOR_ACTIVE)
	menu.add_child(subtitle)
	menu.add_child(HSeparator.new())

	menu.add_child(_make_button("CONTINUE", _resume))
	menu.add_child(_make_button("SAVE GAME", _save))
	menu.add_child(_make_button("SETTINGS", _show_settings))
	menu.add_child(_make_button("QUIT TO DESKTOP", _quit, "danger"))

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.add_theme_color_override("font_color", AshenrootUITheme.COLOR_TEXT_DIM)
	status_label.custom_minimum_size.y = 22
	menu.add_child(status_label)

	settings_panel = _make_panel(Vector2(470, 390))
	settings_panel.visible = false
	overlay.add_child(settings_panel)
	var settings := VBoxContainer.new()
	settings.add_theme_constant_override("separation", 12)
	settings_panel.add_child(settings)
	settings.add_child(_make_title("SETTINGS"))
	settings.add_child(HSeparator.new())

	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = "FULLSCREEN"
	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_toggle.toggled.connect(_set_fullscreen)
	ui_theme.apply_button(fullscreen_toggle)
	settings.add_child(fullscreen_toggle)

	var scale_row := HBoxContainer.new()
	scale_row.add_theme_constant_override("separation", 12)
	settings.add_child(scale_row)
	var scale_label := Label.new()
	scale_label.text = "INTERFACE SCALE"
	scale_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scale_row.add_child(scale_label)
	ui_scale_selector = OptionButton.new()
	for label in ["80%", "90%", "100%", "110%", "120%"]:
		ui_scale_selector.add_item(label)
	ui_scale_selector.select(_scale_to_index(ui_scale))
	ui_scale_selector.item_selected.connect(_select_ui_scale)
	ui_theme.apply_button(ui_scale_selector)
	scale_row.add_child(ui_scale_selector)

	var hint := Label.new()
	hint.text = "Audio settings will be added together with the sound system."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", AshenrootUITheme.COLOR_TEXT_DIM)
	settings.add_child(hint)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings.add_child(spacer)
	settings.add_child(_make_button("BACK", _hide_settings))

	ui_theme.apply_font_tree(self)
	visible = false


func set_open(open: bool) -> void:
	is_open = open
	visible = open
	if open:
		_hide_settings()
		status_label.text = ""


func show_saved_message() -> void:
	if status_label != null:
		status_label.text = "GAME SAVED"


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or not (event is InputEventKey):
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo or key.keycode != KEY_ESCAPE:
		return
	if settings_panel.visible:
		_hide_settings()
	else:
		_resume()
	get_viewport().set_input_as_handled()


func _make_panel(minimum_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = minimum_size
	panel.add_theme_stylebox_override("panel", ui_theme.panel_style("main", 22.0))
	return panel


func _make_title(text: String) -> Label:
	var title := Label.new()
	title.text = text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", AshenrootUITheme.COLOR_TEXT)
	if ui_theme.bold_font != null:
		title.add_theme_font_override("font", ui_theme.bold_font)
	return title


func _make_button(text: String, callback: Callable, variant := "normal") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 46
	button.pressed.connect(callback)
	ui_theme.apply_button(button, variant)
	return button


func _resume() -> void:
	resume_requested.emit()


func _save() -> void:
	save_requested.emit()


func _quit() -> void:
	quit_requested.emit()


func _show_settings() -> void:
	menu_panel.visible = false
	settings_panel.visible = true


func _hide_settings() -> void:
	if menu_panel == null or settings_panel == null:
		return
	menu_panel.visible = true
	settings_panel.visible = false


func _set_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)
	_save_settings()


func _select_ui_scale(index: int) -> void:
	var scales := [0.8, 0.9, 1.0, 1.1, 1.2]
	if index >= 0 and index < scales.size():
		ui_scale = scales[index]
		ui_scale_changed.emit(ui_scale)
		_save_settings()


func _scale_to_index(scale: float) -> int:
	var scales := [0.8, 0.9, 1.0, 1.1, 1.2]
	var closest := 0
	var closest_distance := INF
	for index in range(scales.size()):
		var distance: float = absf(scales[index] - scale)
		if distance < closest_distance:
			closest = index
			closest_distance = distance
	return closest


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	ui_scale = clampf(float(config.get_value("display", "ui_scale", 1.0)), 0.8, 1.2)
	var fullscreen := bool(config.get_value("display", "fullscreen", false))
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("display", "ui_scale", ui_scale)
	config.save(SETTINGS_PATH)

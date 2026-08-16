extends RefCounted
class_name DebugConsoleView

signal command_submitted(command_line: String)
signal close_requested

var panel: PanelContainer
var output: RichTextLabel
var input: LineEdit
var history: Array[String] = []
var history_index := 0
var is_open := false


func setup(canvas: CanvasLayer, ui_theme: AshenrootUITheme = null) -> void:
	panel = PanelContainer.new()
	panel.name = "DebugConsole"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 22
	panel.offset_top = 18
	panel.offset_right = 670
	panel.offset_bottom = 352
	panel.z_index = 200
	panel.visible = false
	if ui_theme != null:
		panel.add_theme_stylebox_override("panel", ui_theme.panel_style("active", 10.0))
	else:
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color("090d12", 0.97)
		panel_style.border_color = Color("6f8d91")
		panel_style.set_border_width_all(1)
		panel_style.set_corner_radius_all(4)
		panel_style.content_margin_left = 12
		panel_style.content_margin_top = 10
		panel_style.content_margin_right = 12
		panel_style.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", panel_style)
	canvas.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "DEV CONSOLE   F1 / `"
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color("9fd3c7"))
	layout.add_child(title)

	output = RichTextLabel.new()
	output.bbcode_enabled = true
	output.fit_content = false
	output.scroll_active = true
	output.custom_minimum_size = Vector2(620, 242)
	output.mouse_filter = Control.MOUSE_FILTER_STOP
	output.add_theme_font_size_override("normal_font_size", 12)
	layout.add_child(output)

	input = LineEdit.new()
	input.placeholder_text = "help"
	input.clear_button_enabled = true
	input.caret_blink = true
	input.add_theme_font_size_override("font_size", 13)
	if ui_theme != null:
		ui_theme.apply_line_edit(input)
	input.text_submitted.connect(_on_command)
	input.gui_input.connect(_on_input)
	layout.add_child(input)


func set_open(open: bool) -> void:
	is_open = open
	if panel == null:
		return
	panel.visible = open
	if open:
		history_index = history.size()
		refocus.call_deferred()
	elif input != null:
		input.release_focus()


func print_line(message: String) -> void:
	if output == null:
		return
	output.append_text(message + "\n")
	output.scroll_to_line(maxi(0, output.get_line_count() - 1))


func refocus() -> void:
	if not is_open or input == null:
		return
	input.grab_focus()
	input.caret_column = input.text.length()


func _on_command(raw_command: String) -> void:
	var command_line := raw_command.strip_edges()
	input.clear()
	if command_line.is_empty():
		refocus.call_deferred()
		return
	history.append(command_line)
	if history.size() > 40:
		history.pop_front()
	history_index = history.size()
	print_line("[color=#82949d]> %s[/color]" % command_line)
	command_submitted.emit(command_line)
	refocus.call_deferred()


func _on_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_UP:
		if not history.is_empty():
			history_index = maxi(0, history_index - 1)
			input.text = history[history_index]
			input.caret_column = input.text.length()
		input.accept_event()
	elif key_event.keycode == KEY_DOWN:
		if not history.is_empty():
			history_index = mini(history.size(), history_index + 1)
			input.text = "" if history_index >= history.size() else history[history_index]
			input.caret_column = input.text.length()
			input.accept_event()
	elif key_event.keycode == KEY_ESCAPE:
		close_requested.emit()
		input.accept_event()

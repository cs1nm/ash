extends Control

const BASE_RADIUS := 86.0
const KNOB_RADIUS := 37.0
const DEAD_ZONE := 0.16

var touch_index := -1
var axis := Vector2.ZERO


func _ready() -> void:
	custom_minimum_size = Vector2(BASE_RADIUS * 2.0, BASE_RADIUS * 2.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _exit_tree() -> void:
	_release_actions()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and touch_index < 0:
			touch_index = touch.index
			_update_axis(touch.position)
			accept_event()
		elif not touch.pressed and touch.index == touch_index:
			touch_index = -1
			axis = Vector2.ZERO
			_apply_actions()
			queue_redraw()
			accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == touch_index:
			_update_axis(drag.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				touch_index = -2
				_update_axis(mouse.position)
			elif touch_index == -2:
				touch_index = -1
				axis = Vector2.ZERO
				_apply_actions()
				queue_redraw()
			accept_event()
	elif event is InputEventMouseMotion and touch_index == -2:
		_update_axis((event as InputEventMouseMotion).position)
		accept_event()


func _update_axis(local_position: Vector2) -> void:
	var center := size * 0.5
	axis = (local_position - center) / BASE_RADIUS
	if axis.length() > 1.0:
		axis = axis.normalized()
	if axis.length() < DEAD_ZONE:
		axis = Vector2.ZERO
	_apply_actions()
	queue_redraw()


func _apply_actions() -> void:
	if axis.x < -DEAD_ZONE:
		Input.action_press("move_left", -axis.x)
	else:
		Input.action_release("move_left")
	if axis.x > DEAD_ZONE:
		Input.action_press("move_right", axis.x)
	else:
		Input.action_release("move_right")
	if axis.y < -0.52:
		Input.action_press("jump", -axis.y)
	else:
		Input.action_release("jump")


func _release_actions() -> void:
	touch_index = -1
	axis = Vector2.ZERO
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, BASE_RADIUS, Color(0.04, 0.07, 0.09, 0.58))
	draw_arc(center, BASE_RADIUS - 2.0, 0.0, TAU, 48, Color(0.62, 0.72, 0.76, 0.82), 3.0, true)
	draw_circle(center + axis * (BASE_RADIUS - KNOB_RADIUS - 5.0), KNOB_RADIUS, Color(0.78, 0.67, 0.32, 0.92))
	draw_arc(center + axis * (BASE_RADIUS - KNOB_RADIUS - 5.0), KNOB_RADIUS, 0.0, TAU, 32, Color(1.0, 0.89, 0.58, 0.95), 2.0, true)

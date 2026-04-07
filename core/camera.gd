extends Camera2D

var zoom_speed := 0.06
var min_zoom := 0.2
var max_zoom := 1.5
var zoom_amount := 0.5

var dragging := false
var last_mouse_pos := Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = get_viewport().get_mouse_position()
			
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(1 - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(1 + zoom_speed)

	elif event is InputEventMouseMotion and dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var delta = mouse_pos - last_mouse_pos

		# Move opposite to drag direction (feels natural)
		position -= delta / zoom

		last_mouse_pos = mouse_pos
		
	if event.is_action_pressed("zoom_in"):
		zoom_camera(1 - zoom_amount)

	elif event.is_action_pressed("zoom_out"):
		zoom_camera(1 + zoom_amount)


func zoom_camera(factor: float):
	var old_zoom = zoom

	# Apply zoom
	zoom *= factor

	# Clamp zoom
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)

	# --- Zoom toward mouse ---
	var mouse_pos = get_viewport().get_mouse_position()
	var before = to_local(mouse_pos)
	var after = to_local(mouse_pos)

	position += before - after

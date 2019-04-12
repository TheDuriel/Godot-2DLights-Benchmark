extends Camera2D

export(int, 50, 1000) var SPEED = 400


func _init() -> void:
	current = true
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false


func _input(event) -> void:
	
	if event is InputEventScreenDrag:
		position += event.relative * 2
	
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		position += event.relative * 2
	
	if event.is_action_pressed("zoom_in"):
		zoom -= Vector2(0.1, 0.1)
	
	elif event.is_action_pressed("zoom_out"):
		zoom += Vector2(0.1, 0.1)
	
	if event.is_action_pressed("reset_camera"):
		position = Vector2()
		zoom = Vector2(1.0, 1.0)
	
	zoom = zoom.snapped(Vector2(0.1, 0.1))
	zoom.x = clamp(zoom.x, 0.2, 4)
	zoom.y = clamp(zoom.y, 0.2, 4)


func _physics_process(delta) -> void:
	
	var keydir = Vector2()
	if Input.is_action_pressed("ui_up"):
		keydir.y -= 1
	if Input.is_action_pressed("ui_down"):
		keydir.y += 1
	if Input.is_action_pressed("ui_left"):
		keydir.x -= 1
	if Input.is_action_pressed("ui_right"):
		keydir.x += 1
	position += keydir * SPEED * delta

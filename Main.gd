extends Node

const texture_256: Texture = preload("images/light_256.png")
const texture_512: Texture = preload("images/light_512.png")
const texture_1024: Texture = preload("images/light_1024.png")
const normal_256: Texture = preload("res://images/Grass-Normal_256.png")
const normal_512: Texture = preload("res://images/Grass-Normal_512.png")

const text_controls = """
### Godot 3.1 Light Benchmark
### Camera ###
W, A, S, D	= Move Camera
Scroll		= Zoom Camera
Middle M.	= Reset Camera
### Base Controls ###
1, 2		= Lights On/Off
3			= Rotation On/Off
Q, E 		= Rotation Speed
### Light Quality ###
F1, F2, F3	= Texture Resolution
CTRL		= Normal Resolution
F			= Buffer Size
4, 5		= Gradient Length
Y, X		= PCF
C, V		= Filter Smooth
"""

const text_monitor = """
FPS 			= %s
IDLE_TIME 		= %s
RESOLUTION 		= %s
NORMAL_RES		= %s
BUFFER_SIZE 	= %s
GRADIENT_LENGTH = %s
FILTER 			= %s
FILTER_SMOOTH 	= %s
"""

onready var controls: Label = $"UI/V/Controls"
onready var monitor: Label = $"UI/V/Monitor"
onready var primary: Node2D = $"LightsPrimary"
onready var secondary: Node2D = $"LightsSecondary"
onready var lights: Array = get_tree().get_nodes_in_group("lights")
onready var background: Node2D = $"Background"
onready var background_tiles: Array = get_tree().get_nodes_in_group("background_tiles")

var rotating: bool = false
var rotation_speed: float = 10.0
var rotation_speed_step: float = 10.0
var buffer_size: int = 2048
var gradient_length: int = 0
var gradient_length_step: int = 2
var filter_smooth: int = 0
var filter_smooth_step: int = 2
var pcf: int = 0
var pcf_steps: Array = [
		0,
		Light2D.SHADOW_FILTER_PCF3,
		Light2D.SHADOW_FILTER_PCF5,
		Light2D.SHADOW_FILTER_PCF7,
		Light2D.SHADOW_FILTER_PCF13,
		]
var shadows: bool = true


func _ready() -> void:
	controls.text = text_controls
	for i in background_tiles:
		i.normal_map = normal_512


func _input(event) -> void:
	
	if event.is_action_pressed("res_1"):
		for i in lights:
			i.texture = texture_256
	elif event.is_action_pressed("res_2"):
		for i in lights:
			i.texture = texture_512
	elif event.is_action_pressed("res_3"):
		for i in lights:
			i.texture = texture_1024
	
	if event.is_action_pressed("rotate_toggle"):
		rotating = true if not rotating else false
	
	if event.is_action("rotate_speed_down"):
		rotation_speed += rotation_speed_step
	elif event.is_action("rotate_speed_up"):
		rotation_speed -= rotation_speed_step
	
	if event.is_action_pressed("toggle_primary"):
		primary.visible = true if not primary.visible else false
	elif event.is_action_pressed("toggle_secondary"):
		secondary.visible = true if not secondary.visible else false
	
	if event.is_action_pressed("toggle_background"):
		background.visible = true if not background.visible else false
	
	if event.is_action_pressed("toggle_background_size"):
		background.scale = Vector2(0.5, 0.5) if background.scale != Vector2(0.5, 0.5) else Vector2(1.0, 1.0)
	
	if event.is_action_pressed("toggle_buffer_size"):
		buffer_size = 2048 if buffer_size == 1024 else 1024
		for i in lights:
			i.shadow_buffer_size = buffer_size
	
	if event.is_action("gradient_length_up"):
		gradient_length += gradient_length_step
		gradient_length = clamp(gradient_length, 0, 32)
		for i in lights:
			i.shadow_gradient_length = gradient_length
	elif event.is_action("gradient_length_down"):
		gradient_length -= gradient_length_step
		gradient_length = clamp(gradient_length, 0, 32)
		for i in lights:
			i.shadow_gradient_length = gradient_length
	
	if event.is_action_pressed("filter_up"):
		pcf += 1
		pcf = clamp(pcf, 0, 4)
		for i in lights:
			i.shadow_filter = pcf_steps[pcf]
	elif event.is_action_pressed("filter_down"):
		pcf -= 1
		pcf = clamp(pcf, 0, 4)
		for i in lights:
			i.shadow_filter = pcf_steps[pcf]
	
	if event.is_action("filter_smooth_up"):
		filter_smooth += filter_smooth_step
		filter_smooth = clamp(filter_smooth, 0, 32)
		for i in lights:
			i.shadow_filter_smooth = filter_smooth
	elif event.is_action("filter_smooth_down"):
		filter_smooth -= filter_smooth_step
		filter_smooth = clamp(filter_smooth, 0, 32)
		for i in lights:
			i.shadow_filter_smooth = filter_smooth
	
	if event.is_action_pressed("toggle_shadows"):
		shadows = true if not shadows else false
		for i in lights:
			i.shadow_enabled = shadows
	
	if event.is_action_pressed("toggle_normals"):
		if background_tiles[0].normal_map.get_height() == 256:
			for i in background_tiles:
				i.normal_map = normal_512
		elif background_tiles[0].normal_map.get_height() == 512:
			for i in background_tiles:
				i.normal_map = normal_256


func _process(delta):
	if rotating:
		primary.rotation_degrees += rotation_speed * delta
		secondary.rotation_degrees += rotation_speed * delta
	
	update_label()


func update_label() -> void:
	var format_strings: Array = [
	Performance.get_monitor(Performance.TIME_FPS),
	Performance.get_monitor(Performance.TIME_PROCESS),
	lights[0].texture.get_height(),
	background_tiles[0].normal_map.get_height(),
	lights[0].shadow_buffer_size,
	lights[0].shadow_gradient_length,
	lights[0].shadow_filter,
	lights[0].shadow_filter_smooth,
	]
	monitor.text = text_monitor % format_strings
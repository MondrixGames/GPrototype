extends Control

var paused = false
@export var player_camera : Camera3D
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	Global.pause_menu = self
	pass # Replace with function body.

func pauseMenu():
	if paused:
		hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		show()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = !paused
	return paused

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_resume_pressed():
	pauseMenu()
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_h_slider_value_changed(value):
	player_camera.environment.background_energy_multiplier = value
	pass # Replace with function body.


func _on_color_picker_button_color_changed(color):
	player_camera.environment.volumetric_fog_albedo = color
	pass # Replace with function body.


func _on_h_slider_2_value_changed(value):
	player_camera.environment.volumetric_fog_density = value
	pass # Replace with function body.


func _on_check_button_toggled(toggled_on):
	player_camera.environment.sdfgi_enabled = toggled_on
	pass # Replace with function body.


func _on_check_button_2_toggled(toggled_on):
	player_camera.environment.ssil_enabled = toggled_on
	pass # Replace with function body.




func _on_h_slider_3_value_changed(value):
	player_camera.environment.tonemap_exposure = value
	pass # Replace with function body.


func _on_color_picker_button_2_color_changed(color):
	player_camera.environment.ambient_light_color = color
	pass # Replace with function body.


func _on_check_button_3_toggled(toggled_on):
	if toggled_on:
		player_camera.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	else:
		player_camera.environment.ambient_light_source = Environment.AMBIENT_SOURCE_BG
	pass # Replace with function body.


func _on_h_slider_4_value_changed(value):
	get_viewport().fsr_sharpness = value
	pass # Replace with function body.


func _on_option_button_item_selected(index):
	const TONEMAPPER = [Environment.TONE_MAPPER_LINEAR, Environment.TONE_MAPPER_FILMIC, Environment.TONE_MAPPER_REINHARDT, Environment.TONE_MAPPER_ACES]
	player_camera.environment.tonemap_mode = TONEMAPPER[index]
	pass # Replace with function body.


func _on_option_button_2_item_selected(index):
	const resolutions = [Vector2i(2560, 1440),
		Vector2i(1920, 1080), Vector2i(1280, 720),
		Vector2i(854, 480), Vector2i(640, 360),
		Vector2i(426, 240), Vector2i(3440, 1440)]
	DisplayServer.window_set_size(resolutions[index])
	pass # Replace with function body.


func _on_check_button_4_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	pass # Replace with function body.

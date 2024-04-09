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

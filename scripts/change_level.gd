extends MeshInstance3D

@export var level_name : String = "main"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_area_3d_body_entered(_body):
	if Input.is_action_just_pressed("shoot"):
		var level = load("res://scenes/%s.tscn" % level_name)
		get_tree().change_scene_to_packed(level)
	pass # Replace with function body.

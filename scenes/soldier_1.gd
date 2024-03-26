extends CharacterBody3D


const SPEED = 5.0

var target_position = Vector3.ZERO
var b_pos = Vector3.ZERO

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var blend_tree = anim_tree.get("parameters/BlendSpace2D/blend_position")

func _ready():
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.autostart = true
	timer.wait_time = 30.0
	timer.timeout.connect(_timer_timeout)
	timer.start()

func _process(delta):
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
	b_pos = velocity.rotated(Vector3.UP, get_rotation().y).normalized()
	anim_tree.set("parameters/BlendSpace2D/blend_position", Vector2(b_pos.x, b_pos.z))
	move_and_slide()

func rand_navpoint():
	var random_point = Vector3(randi_range(-50, 50), randi_range(-50, 50), randi_range(-50, 50))
	nav_agent.set_target_position(global_transform.origin + random_point)

func _timer_timeout():
	rand_navpoint()

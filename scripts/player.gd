extends CharacterBody3D

#region Player Nodes
@onready var head = $head
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var camera_3d = $head/Camera3D
@onready var flashlight = $head/Camera3D/SpotLight3D
@onready var raycast_weapon = $head/Camera3D/RayCastWeapon
@onready var blaster_cooldown = $Cooldown
@onready var container = $head/Camera3D/SubViewportContainer/SubViewport/CameraItem/Container
@onready var subviewport_container = $head/Camera3D/SubViewportContainer

#endregion

#region Speed Variables
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
@export var jump_velocity = 4.5
#endregion

#region Movement Variables
@export var crouching_depth = -0.5

#fov variables
@export var base_fov = 75.0
@export var fov_change = 1.5

var jump_buffer = 0
#endregion

#region Input Variables
@export var mouse_sensitivity = 0.4
@export var zoom_sensitivity = 0.5
var direction = Vector3.ZERO
#endregion

#region FPS variables
@export var weapons: Array[Weapon] = []

var weapon: Weapon
var weapon_index := 0

var tween:Tween
var container_offset = Vector3(1.2, -1.1, -2.75)

@export var crosshair:TextureRect
#endregion
#region Settings

#const resolutions = [Vector2i(192, 108),
		#Vector2i(480, 270), Vector2i(960, 540),
		#Vector2i(1286, 723), Vector2i(1440, 810),
		#Vector2i(1632, 918), Vector2i(1920, 1080),
		#Vector2i(2553, 1436), Vector2i(2880, 1620),
		#Vector2i(3840, 2160), Vector2i(4800, 2700)]
#const scaling_render = [0.1, 0.25, 0.5, 0.67, 0.75, 0.85, 1.00, 1.33, 1.50, 2.00, 2.50]
const scaling_mode_names = ["Bilinear", "FSR 1.0", "FSR 2.2"]
const scaling_mode = [Viewport.SCALING_3D_MODE_BILINEAR, Viewport.SCALING_3D_MODE_FSR, Viewport.SCALING_3D_MODE_FSR2]
const debug_draw_names = ["Normal", "Wireframe"]

var current_debug_draw_index = 0
#var current_resolution_index = 0
var current_res_mode_index = 0
#endregion

#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapon = weapons[weapon_index] # Weapon must never be nil
	initiate_change_weapon(weapon_index)
	#get_viewport().scaling_3d_scale = scaling_render[current_resolution_index]
	get_viewport().scaling_3d_mode = scaling_mode[current_res_mode_index]
	subviewport_container.visible = false
	camera_3d.environment.volumetric_fog_enabled = false
	Engine.max_fps = 60
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _process(delta):
	#region Debug
	if Global.debug.visible:
		Global.debug.add_property("FPS", snappedf(1.0/delta, 0.1), -1)
	gildo_proof()
	#endregion
func _physics_process(delta):
	#region Debug
	if Global.debug.visible:
		Global.debug.add_property("Weapon Cooldown", snappedf(blaster_cooldown.time_left, .1), 1)
		Global.debug.add_property("Movement Speed", velocity, 2)
		Global.debug.add_property("Volumetric Fog (CTRL+R)", camera_3d.environment.volumetric_fog_enabled, 3)
		#Global.debug.add_property("Resolution (CTRL+C)", resolutions[current_resolution_index], 4)
		Global.debug.add_property("Camera Shader (CTRL+E)", subviewport_container.visible, 4)
		Global.debug.add_property("FPS Lock + Vsync (CTRL+V)", DisplayServer.window_get_vsync_mode(), 5)
		Global.debug.add_property("Scaling mode (CTRL+X)", scaling_mode_names[current_res_mode_index], 6)
		Global.debug.add_property("VRAM Usage (MB)", snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1e6, 0.01), 7)
		Global.debug.add_property("VRAM Texture Usage (MB)", snappedf(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1e6, 0.01), 8)
		Global.debug.add_property("RAM Usage (MB)", snappedf(Performance.get_monitor(Performance.MEMORY_STATIC)/1e6, 0.01), 9)
		Global.debug.add_property("Instantiated Primitives", Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), 10)
		Global.debug.add_property("Objects in frame", Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME), 11)
		Global.debug.add_property("Debug Draw (CTRL+Z)", debug_draw_names[current_debug_draw_index], 12)
		Global.debug.add_property("Occlusion (CTRL+F)", get_tree().root.use_occlusion_culling, 13)
	#endregion
	
	if Input.is_action_just_pressed("toggleflashlight"):
		flashlight.visible = !flashlight.visible
	if Input.is_action_just_pressed("activatefpslimit"):
		if Engine.max_fps == 60:
			Engine.max_fps = 0
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		else:
			Engine.max_fps = 60
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	if Input.is_action_just_pressed("togglecamera"):
		subviewport_container.visible = !subviewport_container.visible
		
	if Input.is_action_just_pressed("toggleenvironment"):
		camera_3d.environment.volumetric_fog_enabled = !camera_3d.environment.volumetric_fog_enabled
	
	#if Input.is_action_just_pressed("changeresolution"):
		#current_resolution_index += 1
		#current_resolution_index %= len(scaling_render)
		#get_viewport().scaling_3d_scale = scaling_render[current_resolution_index]
	
	if Input.is_action_just_pressed("togglerendermode"):
		current_res_mode_index += 1
		current_res_mode_index %= len(scaling_mode_names)
		get_viewport().scaling_3d_mode = scaling_mode[current_res_mode_index]
		#DisplayServer.window_set_size(resolutions[current_resolution_index])
	if Input.is_action_just_pressed("changeviewportmode"):
		current_debug_draw_index += 1
		current_debug_draw_index %= len(debug_draw_names)
		if get_viewport().debug_draw == Viewport.DEBUG_DRAW_WIREFRAME:
			camera_3d.environment.background_energy_multiplier = .1
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		else:
			camera_3d.environment.background_energy_multiplier = 3
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	if Input.is_action_just_pressed("zoomin"):
		camera_3d.fov = camera_3d.fov - zoom_sensitivity
	if Input.is_action_just_pressed("zoomout"):
		camera_3d.fov = camera_3d.fov + zoom_sensitivity
	if Input.is_action_just_pressed("zoomreset"):
		camera_3d.fov = 80.0
	if Input.is_action_just_pressed("toggleoccluder"):
		get_tree().root.use_occlusion_culling = !get_tree().root.use_occlusion_culling
	#region Handle Movement State
	if Input.is_action_pressed("crouch"):
		if is_on_floor():
			current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta * 10.0)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	elif !ray_cast_3d.is_colliding():
		crouching_collision_shape.disabled = true
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y, 1.8, delta * 10.0)
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		else:
			current_speed = walking_speed
	#endregion
	
	#region Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	#endregion
	
	#region Shoot
	action_shoot()
	container.position = lerp(container.position, container_offset - (velocity / 30), delta * 10)
	#endregion
	
	#region Weapon Toggle
	
	# Weapon switching
	
	action_weapon_toggle()
	
	#endregion
	
	#region Handle jump.
	if jump_buffer >= 1 and is_on_floor():
		velocity.y = jump_velocity
		jump_buffer = 0
	elif Input.is_action_just_pressed("ui_accept") and !ray_cast_3d.is_colliding() and is_on_floor():
		velocity.y = jump_velocity
		jump_buffer = 0
	elif Input.is_action_just_pressed("ui_accept") and !ray_cast_3d.is_colliding() and !is_on_floor() :
		jump_buffer = jump_buffer + 1
	#endregion
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 15.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 3.0)
	
	#region Camera FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, sprinting_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	#camera_3d.fov = lerp(camera_3d.fov, target_fov, delta * 8.0)
	move_and_slide()


func action_shoot():
	
	if Input.is_action_pressed("shoot"):
	
		if !blaster_cooldown.is_stopped(): return # Cooldown for shooting
		
		
		
		blaster_cooldown.start(weapon.cooldown)
		
		# Shoot the weapon, amount based on shot count
		
		for n in weapon.shot_count:
		
			raycast_weapon.target_position.x = randf_range(-weapon.spread, weapon.spread)
			raycast_weapon.target_position.y = randf_range(-weapon.spread, weapon.spread)
			
			raycast_weapon.force_raycast_update()
			
			if !raycast_weapon.is_colliding(): continue # Don't create impact when raycast_weapon didn't hit
			
			var collider = raycast_weapon.get_collider()
			
			# Hitting an enemy
			
			if collider.has_method("damage"):
				collider.damage(weapon.damage)
			# Creating an impact animation
			
			var impact = preload("res://objects/impact/impact.tscn")
			var impact_instance = impact.instantiate()
			
			impact_instance.play("shot")
			
			get_tree().root.add_child(impact_instance)
			
			impact_instance.position = raycast_weapon.get_collision_point() + (raycast_weapon.get_collision_normal() / 10)
			impact_instance.activate_sparkles()
			impact_instance.look_at(camera_3d.global_transform.origin, Vector3.UP, true)
			
		container.position.z += 0.25 # Knockback of weapon visual
		head.rotate_x(deg_to_rad(weapon.angle_knockback)) # Knockback of camera
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		velocity += transform.basis * Vector3(0, 0, weapon.knockback) # Knockback
			
			# Toggle between available weapons (listed in 'weapons')

func action_weapon_toggle():
	
	if Input.is_action_just_pressed("weapon_toggle"):
		
		weapon_index = wrap(weapon_index + 1, 0, weapons.size())
		initiate_change_weapon(weapon_index)

# Initiates the weapon changing animation (tween)

func initiate_change_weapon(index):
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon) # Changes the model

# Switches the weapon model (off-screen)

func change_weapon():
	
	weapon = weapons[weapon_index]

	# Step 1. Remove previous weapon model(s) from container
	
	for n in container.get_children():
		container.remove_child(n)
	
	# Step 2. Place new weapon model in container
	
	var weapon_model = weapon.model.instantiate()
	container.add_child(weapon_model)
	
	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation
	
	# Step 3. Set model to only render on layer 2 (the weapon camera)
	
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2
		
	# Set weapon data
	
	raycast_weapon.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair

func gildo_proof():
	if global_position.y < -10:
		global_position = Vector3i(0,0,0)


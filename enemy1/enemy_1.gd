extends CharacterBody3D

enum State {
	IDLE,
	MOVE
}

@export_subgroup("Movimiento")
@export var speed: float = 5.0
@export var acceleration: float = 10.0

#region Onready vars 

@onready var anim_tree = $AnimationTree
@onready var nav_agent = $NavigationAgent3D
@onready var blend_space = anim_tree.get("parameters/BlendSpace2D/blend_position")

#endregion

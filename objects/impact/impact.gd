extends AnimatedSprite3D

@onready var chispas = $GPUParticles3D
# Remove this impact effect after the animation has completed
func activate_sparkles():
	chispas.emitting = true

func _on_animation_finished():
	queue_free()

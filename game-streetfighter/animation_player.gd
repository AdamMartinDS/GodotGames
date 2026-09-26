extends AnimationPlayer

@onready var Collisionpolygon2D = $CollisionPolygon2D 

func _on_animation_player_current_animation_changed(name: String) -> void:
	if name == "crouch":
		Collisionpolygon2D.shape.extents()

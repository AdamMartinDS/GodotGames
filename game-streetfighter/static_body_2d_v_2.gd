extends CollisionShape2D

var x_min = 0 
var x_max = 1152



func _on_body_entered(body):
	emit_signal("wrap_needed", Vector2(1024, body.position.y))

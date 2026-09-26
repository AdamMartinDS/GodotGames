extends Area2D

@export var speed = 30
@export var direction = Vector2.RIGHT
var has_collided = false
var shooter : Node 

func _on_ready() -> void:
	$CollisionShape2D.set_deferred("disabled", false)

func screen_wrap():
	if position.x < 0:
		position.x = screen_size 
	if position.x > screen_size:
		position.x = 0

func _physics_process(delta):
	if not has_collided:
		position += direction * speed * delta
		if $AnimatedSprite2D.animation != "in_air":
			$AnimatedSprite2D.play("in_air")
	screen_wrap()

func handle_collision():   
	speed = 0     
	has_collided = true
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("collide")

func _on_body_entered(body: Node2D) -> void:
	if has_collided:
		return  # Already handled collision once  

	if body == shooter:
		return  # Ignore the shooter

	print("hit ", body.name)

func is_node_or_child(node: Node, parent: Node) -> bool:
	var current = node
	while current:
		if current == parent:
			return true
		current = current.get_parent()
	return false

func _on_area_entered(area: Area2D) -> void:
	if has_collided:
		return  
	if is_node_or_child(area, shooter):
		return  
	if area.is_in_group("Projectile"):
		if area.shooter == shooter:
			return
	print("hit ", area.name)

var screen_size = 168

func _on_animated_sprite_2d_animation_finished() -> void:
	var current_a = $AnimatedSprite2D.animation
	$CollisionShape2D.set_deferred("disabled", false)
	queue_free()

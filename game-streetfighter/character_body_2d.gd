extends CharacterBody2D

var speed = 100
var jump_strength = -300
var punch_flag = 0
var h_kick_flag = 0
var s_kick_flag = 0
var shoot_flag = 0
@onready var mark = $ProjectileMark
@export var projectile_scene : PackedScene
var current_anim

@onready var health_bar = get_parent().get_node("UI/PlayerHealth")
@export var max_health: int = 100
var current_health = max_health

func _on_player_health_ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func _on_ready() -> void:
	$PunchHitbox/CollisionShape2D.disabled = true
	$SKickHitbox/CollisionShape2D.disabled = true
	$HKickHitbox/CollisionShape2D.disabled = true

func _on_AnimatedSprite2D_frame_changed():
	var frame = $AnimatedSprite2D.get_frame()
	var current_a = $AnimatedSprite2D.animation

	match current_a:
		"punch":
			handle_punch(frame)
		"side_kick":
			handle_s_kick(frame)
		"hook_kick":
			handle_h_kick(frame)
		"hadoken_a":
			handle_shoot(frame)

func _on_animated_sprite_2d_animation_finished() -> void:
	var current_a = $AnimatedSprite2D.animation
	match current_a:
		"punch":
			$PunchHitbox/CollisionShape2D.disabled = true
			punch_flag = 0
		"side_kick":
			$SKickHitbox/CollisionShape2D.disabled = true
			s_kick_flag = 0
		"hook_kick":
			$HKickHitbox/CollisionShape2D.disabled = true
			h_kick_flag = 0
		"hadoken_a":
			shoot_flag = 0
	handle_idle()

func spawn_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = mark.global_position
	get_parent().add_child(projectile)
	projectile.shooter = self  

func handle_shoot(frame: int) -> void:
	if frame == 3 and shoot_flag == 1:
		spawn_projectile()

func _on_punch_hitbox_area_entered(area: Node2D) -> void:
	if area.is_in_group("Projectile"):
		if area.shooter == self:
			return
		if area.has_method("handle_collision"):
			area.handle_collision()
			print("Projectile Hit PucnhHitBox!")

func handle_punch(frame: int) -> void:
	if frame == 1:
		$PunchHitbox/CollisionShape2D.disabled = false
	else:
		$PunchHitbox/CollisionShape2D.disabled = true


func _on_s_kick_hitbox_area_entered(area: Node2D) -> void:
	if area.is_in_group("Projectile"):
		if area.shooter == self:
			return
		if area.has_method("handle_collision"):
			area.handle_collision()
			print("Projectile Hit SKickHitBox!")

func handle_s_kick(frame: int) -> void:
	if frame == 1 or frame == 2 or frame == 3:
		$SKickHitbox/CollisionShape2D.disabled = false
	else:
		$SKickHitbox/CollisionShape2D.disabled = true

func _on_h_kick_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.shooter == self:
			return
		if area.has_method("handle_collision"):
			area.handle_collision()
			print("Projectile Hit HKickaHitBox!")

func handle_h_kick(frame):
	if frame == 2 :
		$HKickHitbox/CollisionShape2D.disabled = false
	else:
		$HKickHitbox/CollisionShape2D.disabled = true

func update_collision():
	$HurtBoxIdle/CollisionShape2DIdle.disabled = current_anim != "idle"
	$HurtboxJump/CollisionShape2DJump.disabled = current_anim != "jump"
	$HurtBoxCrouch/CollisionShape2D_crouch.disabled = current_anim != "crouch"

func handle_jump():
	velocity.y = jump_strength

func handle_in_air_j():
	$AnimatedSprite2D.play("jump")
	current_anim = "jump"
	update_collision()
	velocity.x *= 0.7

func handle_move_right():
	$AnimatedSprite2D.play("right")
	current_anim = "idle"
	update_collision()

func handle_move_left():
	$AnimatedSprite2D.play("left")
	current_anim = "idle"
	update_collision()

func handle_crouch():
	$AnimatedSprite2D.play("crouch")
	current_anim = "crouch"
	update_collision()

func handle_idle():
	$AnimatedSprite2D.play("idle")
	current_anim = "idle"
	update_collision()

func get_input():
	var input_direction = Input.get_axis("left", "right")
	velocity.x = input_direction * speed
	
	if punch_flag == 1 or s_kick_flag == 1 or h_kick_flag == 1 or shoot_flag == 1:
		velocity.x = 0
		return
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		handle_jump()
	elif Input.is_action_just_pressed("punch") and punch_flag == 0:
		$AnimatedSprite2D.play("punch")
		punch_flag = 1
	elif Input.is_action_just_pressed("sideKick") and s_kick_flag == 0 and is_on_floor():
		$AnimatedSprite2D.play("side_kick")
		s_kick_flag = 1
	elif Input.is_action_just_pressed("hookKick") and s_kick_flag == 0:
		$AnimatedSprite2D.play("hook_kick")
		h_kick_flag = 1
	elif Input.is_action_just_pressed("shoot") and $HadokenCooldown.is_stopped():
		$AnimatedSprite2D.play("hadoken_a")
		$HadokenCooldown.start()
		shoot_flag = 1
	elif not is_on_floor():
		handle_in_air_j()
	elif velocity.x > 0:
		handle_move_right()
	elif velocity.x < 0:
		handle_move_left()
	elif Input.is_action_pressed("crouch"):
		handle_crouch()
	elif punch_flag == 0 and s_kick_flag == 0 and h_kick_flag == 0 and shoot_flag == 0:
		handle_idle()

var screen_size = 168

func screen_wrap():
	if position.x < 0:
		position.x = screen_size 
	if position.x > screen_size:
		position.x = 0



func take_damage(amount):
	current_health = clamp(current_health - amount, 0, max_health)
	health_bar.value = current_health
	if current_health == 0:
		print("Player is defeated!")

func heal(amount):
	current_health = clamp(current_health + amount, 0, max_health)
	health_bar.value = current_health

func _physics_process(delta):
	get_input()
	
	if not is_on_floor():
		velocity.y += 20 
	move_and_slide()
	screen_wrap()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.shooter == self:
			return
		take_damage(20)
		print("Projectile Hit!")
		if area.has_method("handle_collision"):
			area.handle_collision()


func _on_hadoken_cooldown_timeout() -> void:
	pass

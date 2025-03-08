extends CharacterBody2D
class_name Player

@export var player_speed: int = 90
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bottom: Marker2D = $Bottom

func calc_velocity(speed: float, angle: float) -> Vector2:
	var x: int = round(speed * cos(deg_to_rad(angle)))
	var y: int = round(speed * sin(deg_to_rad(angle)))
	return Vector2(x, y)

func _process(_delta: float) -> void:
	if Global.game_paused:
		animated_sprite_2d.stop()
		return

	# Movement
	var move_x: int = 0
	var move_y: int = 0
	if Input.is_action_pressed("move_down"):
		move_y += 1
	if Input.is_action_pressed("move_up"):
		move_y -= 1
	if Input.is_action_pressed("move_left"):
		move_x -= 1
	if Input.is_action_pressed("move_right"):
		move_x += 1
	if move_x or move_y:
		var move_angle: int
		if move_x < 0 and move_y < 0:
			move_angle = 315
		elif move_x < 0 and move_y > 0:
			move_angle = 225
		elif move_x > 0 and move_y < 0:
			move_angle = 45
		elif move_x > 0 and move_y > 0:
			move_angle = 135
		elif move_x > 0:
			move_angle = 90
		elif move_x < 0:
			move_angle = 270
		elif move_y < 0:
			move_angle = 0
		else:
			move_angle = 180
		move_angle -= 90  # 0 is to the right
		velocity = calc_velocity(player_speed, move_angle)
	else:
		velocity = Vector2.ZERO

	if move_and_slide():
		for i: int in get_slide_collision_count():
			var collision: KinematicCollision2D = get_slide_collision(i)
			var body: RigidBody2D = collision.get_collider() as RigidBody2D
			if body:
				body.apply_force(-100.0 * collision.get_normal())

	# Animation
	if move_y > 0 and animated_sprite_2d.animation != "down":
		if not (
			move_x > 0 and animated_sprite_2d.animation == "right" and animated_sprite_2d.flip_h == false
			or move_x < 0 and animated_sprite_2d.animation == "right" and animated_sprite_2d.flip_h == true
		):
			animated_sprite_2d.play("front")
			animated_sprite_2d.flip_h = false
	elif move_y < 0 and animated_sprite_2d.animation != "up":
		if not (
			move_x > 0 and animated_sprite_2d.animation == "right" and animated_sprite_2d.flip_h == false
			or move_x < 0 and animated_sprite_2d.animation == "right" and animated_sprite_2d.flip_h == true
		):
			animated_sprite_2d.play("back")
			animated_sprite_2d.flip_h = false
	elif move_x < 0 and (animated_sprite_2d.animation != "right" or not animated_sprite_2d.flip_h):
		animated_sprite_2d.play("right")
		animated_sprite_2d.flip_h = true
	elif move_x > 0 and (animated_sprite_2d.animation != "right" or animated_sprite_2d.flip_h):
		animated_sprite_2d.play("right")
		animated_sprite_2d.flip_h = false
	if not velocity and animated_sprite_2d.is_playing():
		animated_sprite_2d.stop()
	elif velocity and not animated_sprite_2d.is_playing():
		animated_sprite_2d.play(animated_sprite_2d.animation)

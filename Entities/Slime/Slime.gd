extends KinematicBody2D


# floor normal to know where the gravity is pointing
const FLOOR_NORMAL: Vector2 = Vector2.UP
# movement speed
export var speed: int = 50
# gravity force
export var gravity: int = 2000
# velocity variable
var velocity: Vector2 = Vector2.ZERO

# slime max health
const MAX_HEALTH: int = 50
# slime health variable
var health: float = MAX_HEALTH

# damage
var attack_damage: float = 30

# variable for other animation playing
var other_animation_playing: bool = false


func _ready() -> void:
	# stop processing until visibl
	set_physics_process(false)
	# set the velocity to walk to the left
	velocity.x = -50

func _physics_process(delta: float) -> void:
	# add gravity
	velocity.y += gravity * delta
	# check if a wall is hit
	if is_on_wall():
		# flip the horizontal velocity (direction)
		velocity.x *= -1.0
		# flip the animation horizontally
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	# move the slime without changing the horizontal movement speed
	velocity.y = move_and_slide(velocity, FLOOR_NORMAL).y
	# check if not playing another animation than the walking one
	if not other_animation_playing:
		# play the walking animation
		$AnimatedSprite.play("walk")


func hit(damage: float) -> void:
	# subtract the damage taken
	health -= damage
	# check if still alive
	if health > 0:
		# play the get hit animation
		$AnimatedSprite.play("hit")
	# in case of death
	else:
		# disable the physics and movement
		set_physics_process(false)
		# play the death animation
		$AnimatedSprite.play("death")
	# set the animation check to the state of playing
	other_animation_playing = true


func die() -> void:
	# disappear
	queue_free()


func _on_AnimatedSprite_animation_finished() -> void:
	# if done dying then please rest in pieace or pieaces
	if $AnimatedSprite.animation == "death":
		die()
	# set the animation check to not playing
	other_animation_playing = false

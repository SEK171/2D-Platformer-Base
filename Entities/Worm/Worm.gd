extends KinematicBody2D


# floor normal to know hwere the gravity is pointing at
const FLOOR_NORMAL: Vector2 = Vector2.UP
# movement speed variable
export var speed: int = 25
# gravity force applied
export var gravity: int = 2000
# variable for velocity
var velocity: Vector2 = Vector2.ZERO

# worm max health
const MAX_HEALTH: int = 20
# worm health variable
var health: float = MAX_HEALTH

# damage applied
var attack_damage: float = 45

# variable for other animation playing
var other_animation_playing: bool = false


func _ready() -> void:
	# stop processing until visible
	set_physics_process(false)
	# set the velocityy to walk to the left
	velocity.x = -speed



func _physics_process(delta: float) -> void:
	# add gravity tot he worm
	velocity.y += gravity * delta
	# check if wall is hit
	if is_on_wall():
		# flip the horizontal movement velocity
		velocity.x *= -1
		# flip the animation horizontally
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	# move the worm without changing the horizontal movement speed
	velocity.y = move_and_slide(velocity, FLOOR_NORMAL).y
	# check if not playing another animation than walking
	if not other_animation_playing:
		# play the walking animation
		$AnimatedSprite.play("walk")


func hit(damage: float) -> void:
	# subtract the damage taken
	health -= damage
	
	# check if still alive
	if health > 0:
		# playt the get hit animation
		$AnimatedSprite.play("hit")
	# in the case of death
	else:
		#disable physics and movement
		set_physics_process(false)
		# play the death animation
		$AnimatedSprite.play("death")
	# set the animation check to playing
	other_animation_playing = true


func die() -> void:
	queue_free()


func _on_AnimatedSprite_animation_finished():
	# if done dying the rest in pieace and pieaces
	if $AnimatedSprite.animation == "death":
		die()
	# set the animation check to not playing
	other_animation_playing = false

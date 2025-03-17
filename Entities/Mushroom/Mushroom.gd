extends KinematicBody2D


# floor normal to know where the gravity is pointing
const FLOOR_NORMAL: Vector2 = Vector2.UP
# movement speed
export var speed: int = 70
# gravity force
export var gravity: int = 2000
# the stomp impulse of jumping on the mushroom
export var stomp_impulse: int = 500
# velocity variable
var velocity: Vector2 = Vector2.ZERO

# slime max health
const MAX_HEALTH: int = 50
# slime health variable
var health: float = MAX_HEALTH

# damage
var attack_damage: float = 20

# variable for other animation playing
var other_animation_playing: bool = false


func _ready() -> void:
	# stop processing until visibl to the player
	set_physics_process(false)
	# set the velocity to start walking to the left
	velocity.x = -speed


func _physics_process(delta: float) -> void:
	# add gravity to the mushroom
	velocity.y += gravity * delta
	# check if a wall is hit
	if is_on_wall():
		# flip the horizontal movement velocity
		velocity.x *= -1.0
		# flip the animation horizontally
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
	# move without changing horizontal movement
	velocity.y = move_and_slide(velocity, FLOOR_NORMAL).y
	# check if not playing another animation other than walk
	if not other_animation_playing:
		# play the walking animation
		$AnimatedSprite.play("walk")


func hit(damage: float) -> void:
	# subtract the damage taken
	health -= damage
	# check if still alive
	if health > 0:
		# play the hit animation
		$AnimatedSprite.play("hit")
	# in case of the dead
	else:
		# disable the physics and movement
		set_physics_process(false)
		# play the death animation
		$ AnimatedSprite.play("death")
	# set the animation check state to playing
	other_animation_playing = true


func die() -> void:
	# disappear
	queue_free()


func _on_AnimatedSprite_animation_finished() -> void:
	# if done dying then rest forver
	if $AnimatedSprite.animation == "death":
		die()
	# set the animation check state to not playing
	other_animation_playing = false


func _on_StompDetector_body_entered(body: Node) -> void:
	# check if the body entering is the player
	if body.name == "Player":
		# play the stomping animation
		$AnimatedSprite.play("crushed")
		# make the player jump
		body.velocity.y = -stomp_impulse
		# set the animation check to playing
		other_animation_playing = true

extends KinematicBody2D


# floor normal to know where the ground is at
const FLOOR_NORMAL: Vector2 = Vector2.UP
# mouvement speed
export var speed: Vector2 = Vector2(200, 400)
# gravity force
export var gravity: int = 2000
# velocity variable
var velocity: Vector2 = Vector2.ZERO

# player max health
const MAX_HEALTH: int = 100
#player health variable
var health: float = MAX_HEALTH

# attack cooldown
const attack_cooldown_time: int = 1000
# indicator for the next time an attack is possible
var next_attack_time: int = 0
# attack damage delt by the player
var attack_damage: float = 30
# variable for weather the player is currently doing something or not
var other_animation_playing: bool = false


func _process(delta: float) -> void:
	# check if doing anything
	if not other_animation_playing:
		# change the animation according to the direction
		change_animation()


func _physics_process(delta: float) -> void:
	# get the direction of movement
	var direction: Vector2 = get_direction()
	# calculate the movement velocity
	velocity = calculate_move_velocity(velocity, direction, speed, delta)
	# move the player
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func _input(event: InputEvent) -> void:
	# check if attack button is pressed
	if event.is_action_pressed("attack"):
		# check if player can attack
		var now: int = OS.get_ticks_msec()
		if now >= next_attack_time:
			# initiate variable to hold the target information
			var targets: Array = $Sword.get_overlapping_bodies()
			# loop through the list
			for target in targets:
				#check if there is a target
				if target != null:
					# check if the target is an enemy
					if target.is_in_group("Enemies"):
						# hit the target
						target.hit(attack_damage)
			# set the animation state to playing
			other_animation_playing = true
			# play the attacking animation
			animate_attack()
			# add couldown to the next attack time
			next_attack_time = now + attack_cooldown_time


func change_animation() -> void:
	# check if looking to the right
	if velocity.x > 0:
		$AnimatedSprite.flip_h = false
		move_swoard(true)
	# check if looking left
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = true
		move_swoard(false)
	# check if jumping up
	if velocity.y < 0:
		$AnimatedSprite.play("jump_up")
	# check if falling down
	elif velocity.y > 0 and not is_on_floor():
		$AnimatedSprite.play("jump_down")
	# check if rolling on the floor
	elif Input.is_action_pressed("roll") and is_on_floor():
		$AnimatedSprite.play("roll")
	else:
		#check if moving
		if velocity.x != 0:
			$AnimatedSprite.play("run")
		else:
			$AnimatedSprite.play("idle")


func move_swoard(direction: bool) -> void:
	# check if looking to the right
	if direction:
		# set the swords position
		$Sword/Sprite.position.x = 15
		# set the sword sprite
		$Sword/Sprite.flip_h = false
		# offset the collision shape
		$Sword/CollisionShape2D.position.x = 12.5
	# in case of looking to the left
	else:
		# set the swords position
		$Sword/Sprite.position.x = -15
		# set the sword sprite
		$Sword/Sprite.flip_h = true
		# offset the collision shape
		$Sword/CollisionShape2D.position.x = -12.5


func animate_attack() -> void:
	# show the sword
	$Sword.visible = true
	# animate the player
	$AnimatedSprite.play("attack")
	# animate the sword
	$Sword/AnimationPlayer.play("slash")
	#wait for the animation to finish
	yield($AnimatedSprite, "animation_finished")
	# hide the sword
	$Sword.visible = false


func get_direction() -> Vector2:
	# return a vector of horizontal and vertical movement direction
	return Vector2(
		Input.get_action_strength("right") \
			- Input.get_action_strength("left"),
		-1.0 if Input.is_action_just_pressed("up") \
			and is_on_floor() else 0.0
	)


func calculate_move_velocity(
		old_velocity: Vector2,
		direction: Vector2,
		_speed: Vector2,
		delta: float
	) -> Vector2:
	# initiate the new velocity
	var new_velocity: Vector2 = old_velocity
	# set the horizontal velocity
	new_velocity.x = _speed.x * direction.x
	# add the effect of gravity to the vertical velocity
	new_velocity.y += gravity * delta
	# check if jumping
	if direction.y == -1.0:
		# set the vertical velocity
		new_velocity.y = _speed.y * direction.y
	# return the new velocity
	return new_velocity


func hit(damage: float) -> void:
	# subtracte the damage taken
	health -= damage
	# check if still alive
	if health > 0:
		# play the get hit animation
		$AnimatedSprite.play("hit")
	# in case of death
	else:
		# disable processing
		set_process(false)
		# disable physics and movement
		set_physics_process(false)
		# play the death animation
		$AnimatedSprite.play("death")
		# die please
		die()
	# set the animation check to playing
	other_animation_playing = true


func die() -> void:
	# play the death animation
	queue_free()


func _on_AnimatedSprite_animation_finished() -> void:
	# animation is done playing
	other_animation_playing = false

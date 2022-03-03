# Skeleton enemy scripts

extends KinematicBody2D

# Physics settings
var _direction = Vector2.ZERO
var _velocity = Vector2.ZERO
export var _speed = 150.0
export var _gravity = 75.0

# Enemy starting health
export var _health = 2

# Boolean control
var _playerdetected = false
var _isdead = false
var _isattacking = false
var _walkingsoundplaying = false

# Signal when the enemy dies, diving xp
signal xp_collected

func _ready():
	$Label.visible = false

func _physics_process(_delta):
	# Enemy actions and movement function
	enemy_actions_and_movement()

func enemy_actions_and_movement():
	
	if !_isdead:
		if !_isattacking:
			if _direction.x > 0:
				$FloorChecker.position.x = 10
				$CollisionShape2D.position.x = -5.4
				$DamagePlayer/Weapon.position.x = 12
				$TopDamage/CollisionShape2D.position.x = -5.4
			else:
				$FloorChecker.position.x = -8 
				$CollisionShape2D.position.x = 4.2
				$DamagePlayer/Weapon.position.x = -9.4
				$TopDamage/CollisionShape2D.position.x = 4.2

			# Changes direction if hits a wall
			if is_on_wall():
				_direction.x = _direction.x * -1

			# Changes direction if end of floor
			if !$FloorChecker.is_colliding():
				_direction.x = _direction.x * -1

			# Plays movement animation
			if _direction.x != 0:
				if !_walkingsoundplaying:
					_walkingsoundplaying = true
					$SkelWalking.play()

				$AnimatedSprite.play("Move")
				$AnimatedSprite.flip_v = false
				$AnimatedSprite.flip_h = _direction.x < 0

			_velocity.x = _direction.x * _speed
			_velocity.y += _gravity

			_velocity = move_and_slide(_velocity, Vector2.UP)

		# Attacks player if on range
		if $AttackPlayer.overlaps_body(get_parent().get_node("Player")) and !_isattacking:
			$SkelAtk.play()
			$AnimatedSprite.play("Attack")
			$DamagePlayer/Weapon.disabled = false
			_isattacking = true
			$AttackTimer.start()

		# Plays death animation on death
		if _health <= 0:
			$AudioTimer.start()
			_isdead = true
			$AnimatedSprite.play("Dead")
			set_physics_process(false)
			set_collision_mask_bit(0, false)
			set_collision_mask_bit(5, false)
			set_collision_layer_bit(4, false)
			$DamagePlayer/Weapon.disabled = true
			$TopDamage/CollisionShape2D.set_deferred("disabled", true)
			emit_signal("xp_collected")
			$XPAnimation.play("XP")
			$DeleteTimer.start()

# Takes damage if hit by player
func take_damage(var player_position):
	if !_isdead:
		_health -= 1
		$AnimatedSprite.stop()
		$AnimatedSprite.play("Hit")
		_direction = Vector2.ZERO
		_velocity = Vector2.ZERO

		var _move_timer = Timer.new()
		_move_timer.set_wait_time(1.5)
		_move_timer.set_one_shot(true)
		self.add_child(_move_timer)
		_move_timer.start()
		yield(_move_timer, "timeout")

		if position.x < player_position:
			_direction.x = 1

		if position.x > player_position:
			_direction.x = -1

		_move_timer.queue_free()

# Detects player and move in its direction
func _on_DetectPlayer_body_entered(body):
	if !_isdead:
		if !_playerdetected:
			_playerdetected = true
			$AnimatedSprite.play("React")
			var _wait_timer = $WaitTimer
			_wait_timer.set_wait_time(0.5)
			_wait_timer.set_one_shot(true)
			_wait_timer.start()
			yield(_wait_timer, "timeout")
			if body.global_position.x < global_position.x:
				_direction.x = -1
			if body.global_position.x > global_position.x:
				_direction.x = 1
			_wait_timer.set_wait_time(1)
			_wait_timer.set_one_shot(true)
			_wait_timer.start()
			yield(_wait_timer, "timeout")
			_playerdetected = false

# Timer before attacks
func _on_AttackTimer_timeout():
	_isattacking = false
	$DamagePlayer/Weapon.disabled = true

# Damage the player if the enemy hits with weapon
func _on_DamagePlayer_body_entered(body):
	body.take_damage(position.x)

# Damage the player if the player touchs the enemy
func _on_TopDamage_body_entered(body):
	body.take_damage(position.x)

# Delete enemy on death after the timer
func _on_DeleteTimer_timeout():
	queue_free()

# Plays moving sound when the enemy moves
func _on_AudioTimer_timeout():
	$SkelDeath.play()

# Stop moving sound when the enemy stops
func _on_SkelWalking_finished():
	_walkingsoundplaying = false

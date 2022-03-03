# Player scripts

extends KinematicBody2D

# Physics settings
var _velocity = Vector2.ZERO
var _direction = Vector2.ZERO
export var _gravity = 75.0

# Player move speed
export var _speed = 300.0

# Player jump height
export var _jump_impulse = -1000.0

# Player starting health
export var _health = 10

# Player attack combo control
var _attackcombo = 0

# Boolean control
var _iscrouched = false
var _isattacking = false
var _hasdoublejump = true
var _doublejumping = false

# Signal when the player dies
signal player_died

func _ready():
	$Label.visible = false
	$something.visible = false
	_hasdoublejump = false

func _physics_process(delta):
	
	# Player actions and movement function
	player_actions_and_movement()

	# Play death animation if the player dies
	if _health <= 0:
		pass
		$AnimatedSprite.play("Dead")
		set_collision_mask_bit(0, false)
		set_collision_mask_bit(4, false)
		set_collision_layer_bit(0, false)
		$SwordHit/CollisionShape2D.set_deferred("disabled", true)
		if is_on_floor():
			set_physics_process(false)
		emit_signal("player_died")

# Player input and animation
func player_actions_and_movement():
	var _direction = Vector2.ZERO

	if Input.is_action_pressed("move_right") and !_iscrouched and !_isattacking:
		_direction.x += 1
	if Input.is_action_pressed("move_left") and !_iscrouched and !_isattacking:
		_direction.x += -1

	if _direction.length() > 0:
		_direction = _direction.normalized()

	if _direction.x != 0:
		$AnimatedSprite.play("Run")
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = _direction.x < 0
		if _direction.x > 0:
			$CollisionShape2D.position.x = -6
			$SwordHit/CollisionShape2D.position.x = 16
		else:
			$CollisionShape2D.position.x = 6
			$SwordHit/CollisionShape2D.position.x = -19

	else:
		if !_isattacking:
			$AnimatedSprite.play("Idle")

	if Input.is_action_just_pressed("jump") and !_isattacking:
		if is_on_floor():
			_doublejumping = false
			$AudioJump.play()
			_velocity.y += _jump_impulse
			_iscrouched = false
		elif !is_on_floor() and _hasdoublejump and !_doublejumping:
			_doublejumping = true
			$AudioJump.play()
			_velocity.y += _jump_impulse * 0.5

	_velocity.x = _direction.x * _speed
	_velocity.y += _gravity

	_velocity = move_and_slide(_velocity, Vector2.UP)

	if !is_on_floor():
		if _velocity.y < 0:
			$AnimatedSprite.play("Jump")
		else:
			$AnimatedSprite.play("Fall")

	if Input.is_action_pressed("crouch") and is_on_floor():
		$AnimatedSprite.play("CrouchPress")
		_iscrouched = true
	if Input.is_action_just_released("crouch") and is_on_floor():
		$AnimatedSprite.play("CrouchRelease")
		_iscrouched = false

	if !_isattacking and Input.is_action_just_pressed("attack") and is_on_floor() and _attackcombo < 1:
		$SwordHit/CollisionShape2D.set_deferred("disabled", false)
		$AudioAtk1.play()
		$AnimatedSprite.play("Attack1")
		_isattacking = true
		_attackcombo += 2
		$AttackTimer.start()
		$ComboDelay.start()

# Attack combo reset
func _on_AttackTimer_timeout():
	$AnimatedSprite.play("Idle")
	_isattacking = false
	_attackcombo = 0
	$SwordHit/CollisionShape2D.set_deferred("disabled", true)

# Delay between combo attacks
func _on_ComboDelay_timeout():
	if _isattacking and Input.is_action_just_pressed("attack") and is_on_floor() and _attackcombo > 1:
		$AudioAtk2.play()
		$AnimatedSprite.play("Attack2")
		$SwordHit/CollisionShape2D.set_deferred("disabled", false)

# Process sword hit
func _on_SwordHit_body_entered(body):
	body.take_damage(position.x)

# Take damage, plays sound and animation when hit
func take_damage(var enemy_position):
	_health -= 1

	$CharHurt.play()
	$AnimatedSprite.stop()
	$AnimatedSprite.play("Hurt")

	set_physics_process(false)
	var _wait_timer = Timer.new()
	_wait_timer.set_wait_time(0.2)
	_wait_timer.set_one_shot(true)
	self.add_child(_wait_timer)
	_wait_timer.start()
	yield(_wait_timer, "timeout")
	set_physics_process(true)
	_wait_timer.queue_free()

	_direction = Vector2.ZERO
	_velocity = Vector2.ZERO

	_velocity.y = -400
	if position.x < enemy_position:
		move_and_slide(Vector2(-2000,0), Vector2.UP)
		Input.action_release("move_right")

	if position.x > enemy_position:
		move_and_slide(Vector2(2000,0), Vector2.UP)
		Input.action_release("move_left")

# Shows text when the Double Jump skill is learned
func _on_HUD_learnDJ():
		$DjAcquired.stream.loop = false
		$DjAcquired.play()
		$DJAnimation.play("XP")
		_hasdoublejump = true

# Shows text when the Boss on the second level is coming
func _on_HUD_somethingis():
		$DJAnimation.play("something")

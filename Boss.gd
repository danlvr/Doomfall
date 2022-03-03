# End boss scripts

extends KinematicBody2D

# Physics settings
var _direction = Vector2.ZERO
var _velocity = Vector2.ZERO
export var _gravity = 75.0

# Set Boss start location
var _startlocation = Vector2(320, 485)

# Initial interval between casting spell
var _spellinterval = 2

# Boss starting health
export var _health = 4

# Boolean control
var _isdead = false
var _castingspell = false

# Boss spell reference
export (PackedScene) var Spell

# Get the player node
onready var Player = get_parent().get_node("Player")

# Signal when the boss dies
signal boss_died

func _ready():
	position = _startlocation
	randomize()

func _physics_process(_delta):
	# If the boss isn't dead or isn't already casting, cast the spell
	if !_isdead:
		if !_castingspell:
			_castingspell = true
			$SpellTimer.start(_spellinterval)

		_velocity.y += _gravity
		_velocity = move_and_slide(_velocity, Vector2.UP)

		# Play boss animation on death
		if _health <= 0:
			_isdead = true
			$AnimatedSprite.play("Dead")
			set_physics_process(false)
			set_collision_mask_bit(0, false)
			set_collision_mask_bit(5, false)
			set_collision_layer_bit(4, false)
			emit_signal("boss_died")

# Take damage function do reduce health and play hit animation
func take_damage(var player_position):
	if !_isdead:
		$BossHurt.play()
		_health -= 1
		$AnimatedSprite.stop()
		$AnimatedSprite.play("Hit")
		
		# Increase casting speed and change boss location
		if _health == 3:
			_spellinterval = 1.5
			position = Vector2(2025, 378)
			$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
			$CollisionShape2D.position.x = -32.4
		if _health == 2:
			_spellinterval = 1
			position = Vector2(1242, 352)
			$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
			$CollisionShape2D.position.x = -108.006
		if _health == 1:
			_spellinterval = 0.5
			position = Vector2(594, 419)
			$CollisionShape2D.position.x = -108.006

# Casting animation and spell spawning
func _on_SpellTimer_timeout():
	if !_isdead:
		$AnimatedSprite.play("Cast")

		var _cast_timer = Timer.new()
		_cast_timer.set_wait_time(0.5)
		_cast_timer.set_one_shot(true)
		self.add_child(_cast_timer)
		_cast_timer.start()
		yield(_cast_timer, "timeout")
		_cast_timer.queue_free()

		var _castedspell = Spell.instance()
		add_child(_castedspell)
		_castedspell.global_position = Player.global_position + Vector2(36,-75) + Vector2(rand_range(-100,100),0) 
		
		_castingspell = false

# Return to idle animation while not casting
func _on_AnimatedSprite_animation_finished():
	if !_isdead:
		$AnimatedSprite.play("Idle")

# Boss spell animation and damage

extends Node2D

func _ready():
	$PreAnimation.play("Pre")
	$Damage/CollisionShape2D.set_deferred("disabled", true)

# Plays spell animation
func _on_PreAnimation_animation_finished():
		$PreAnimation.play("Anim")
		$Lightning.play()
		$Delete.start()
		$Colision.start()

# Do damage to the player if the spell hits
func _on_Damage_body_entered(body):
	$Damage/CollisionShape2D.set_deferred("disabled", true)
	body.take_damage(position.x)

# Delete instantiated spell after the timer
func _on_Delete_timeout():
	queue_free()

# Disable the spell collision after the timer
func _on_Colision_timeout():
	$Damage/CollisionShape2D.set_deferred("disabled", false)

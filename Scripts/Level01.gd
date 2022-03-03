# Level 01 specific scripts

extends Node2D

func _ready():
	$HUD/GameOver.visible = false
	$HUD/Text/AnimationPlayer.play("Text")
	$Player.set_physics_process(false)

# Shows GameOver screen on player's death
func _on_Player_player_died():
	$HUD/GameOver.visible = true
	$HUD/Topleft.visible = false
	$HUD/GameOverLoad.play("GameOver")

# GameOver screen Quit game
func _on_Start2_pressed():
	get_tree().quit()

# GameOver screen Restart Level
func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/Level01.tscn")

# When the player enters the portal to the next level
func _on_Area2D_body_entered(body):
	$Player.set_physics_process(false)
	$Portal/LevelTransition.play("transition")
	$AudioStreamPlayer.stop()
	$AudioPortal.play()

# Change scene after the portal animation
func _on_LevelTransition_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/Level02.tscn")

# After the portal animation has finished restore player controls
func _on_AnimationPlayer_animation_finished(anim_name):
	$Player.set_physics_process(true)

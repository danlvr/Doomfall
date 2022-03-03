# Level 02 specific scripts

extends Node2D

# Boss preload and instance
var Boss = preload("res://Scenes/Boss.tscn")
var boss = Boss.instance()

func _ready():
	$HUD/GameOver.visible = false
	$Player._hasdoublejump = true	

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
	get_tree().change_scene("res://Scenes/Level02.tscn")

# When the boss spawned, cast spell and connect boss death signal to the instance
func _on_HUD_somethingis():
		$Level.stop()
		$BossSound.play(13)

		var cast_timer = Timer.new()
		cast_timer.set_wait_time(2)
		cast_timer.set_one_shot(true)
		self.add_child(cast_timer)
		cast_timer.start()
		yield(cast_timer, "timeout")
		cast_timer.queue_free()

		add_child(boss)
		boss.connect("boss_died", self, "_on_Boss_died")

# After the boss is defeated plays sound, animation and camera effect 
func _on_Boss_died():
	$EndTimer.start()
	$BossSound.stop()
	$Laugher.play()
	$Earthquake.play()
	$Player/Camera2D.shake(10,100,5)

# After the boss is defeated go to the end screen
func _on_EndTimer_timeout():
	get_tree().change_scene("res://Scenes/End.tscn")

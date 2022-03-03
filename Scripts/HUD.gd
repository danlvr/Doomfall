# Player hidden HUD information

extends CanvasLayer

# Starting XP
var _xp = 0

# Signal when get enough xp to learn Double Jump skill
signal learnDJ

# Signal when all skeletons are killed in the seconds level, starting the Boss
signal somethingis

func _on_Skeleton_xp_collected():
	_xp += 10
	if _xp >= 50:
		emit_signal("learnDJ")

func _on_Skeleton_Level2_xp_collected():
	_xp += 10
	if _xp >= 70:
		emit_signal("somethingis")

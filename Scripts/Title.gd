# Title screen animation and menu

extends Control

func _ready():
	pass

func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/Level01.tscn")

func _on_Start2_pressed():
	get_tree().quit()

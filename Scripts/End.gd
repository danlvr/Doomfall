# End screen animation and menu

extends Control

func _ready():
	pass

func _process(delta):
	$ParallaxBackground.scroll_offset.x += 6

func _on_Start2_pressed():
	get_tree().quit()

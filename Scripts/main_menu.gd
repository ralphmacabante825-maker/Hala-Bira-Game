extends Control

func _ready():
	pass

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://Main World1.tscn")

extends Control

var main := "res://Scenes/main.tscn"

func _on_start_button_click_end():
	var _level = get_tree().change_scene_to_file(main)

func _on_exit_button_click_end():
	get_tree().quit()

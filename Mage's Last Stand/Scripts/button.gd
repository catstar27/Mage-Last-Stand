extends Button

signal click_end()

func _on_mouse_entered():
	$HoverSound.play()

func _on_pressed():
	$ClickSound.play()

func _on_click_sound_finished():
	emit_signal("click_end")

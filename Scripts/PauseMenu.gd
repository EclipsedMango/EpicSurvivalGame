extends Control

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func _on_resume_pressed():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_exit_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

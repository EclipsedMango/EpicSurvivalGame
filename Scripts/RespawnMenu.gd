extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_respawn_pressed():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_parent().respawn_player()

func _on_exit_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

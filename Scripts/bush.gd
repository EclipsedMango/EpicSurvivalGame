extends Node3D

@onready var model: Node3D = $TestBush4
@onready var mesh: MeshInstance3D = $TestBush4/Plane_001

func _process(delta: float) -> void:
	model.visible = get_viewport().get_camera_3d().global_position.distance_to(global_position) < 20

extends Area3D

@onready var node: Node = $"../MultiMeshInstance3D"


func _ready():
	node.visible = false


func _on_body_entered(body):
	if body is Player: 
		node.visible = true


func _on_body_exited(body):
	if body is Player: 
		node.visible = false

class_name DroppedItem
extends RigidBody3D

var item: ItemStack

func _ready() -> void:
	var display = ItemStack.type_display[item.type].instantiate()
	add_child(display)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.inventory.add_item(item)
		queue_free()

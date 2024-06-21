class_name ItemStack
extends RefCounted

var type: ItemType
var amount: int = 1

func _init(t: ItemType) -> void:
	type = t

enum ItemType {
	Rock,
	Wood,
	Sword,
	Pickaxe,
	Axe,
}

class_name ItemStack
extends RefCounted

var type: ItemType
var amount: int = 1

enum ItemType {
	Rock,
	Wood,
	Sword,
	Pickaxe,
	Axe,
}

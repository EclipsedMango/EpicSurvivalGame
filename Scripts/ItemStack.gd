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

static var type_names: Array[String] = [
	"Rock",
	"Wood",
	"Sword",
	"Pickaxe",
	"Axe",
]

static var type_display: Array[PackedScene] = [
	preload("res://Scenes/Items/rock_display.tscn"),
	preload("res://Scenes/Items/log_display.tscn"),
]

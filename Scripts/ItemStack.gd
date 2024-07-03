class_name ItemStack
extends RefCounted

var type: ItemType
var amount: int = 1

func _init(t: ItemType, count: int = 1) -> void:
	amount = count
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

static var type_icons: Array[Texture2D] = [
	preload("res://Assets/Art/Textures/rockICON.png"),
	preload("res://Assets/Art/Textures/logICON.png"),
	preload("res://icon.svg"),
	preload("res://Assets/Art/Textures/pickaxeICONdownSIZED.png"),
	preload("res://icon.svg"),
]

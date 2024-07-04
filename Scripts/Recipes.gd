class_name Recipes
extends RefCounted

static var recipes: Array = [
	{"result": ItemStack.new(ItemStack.ItemType.Pickaxe), "ingredients": [
		ItemStack.new(ItemStack.ItemType.Wood, 5), 
		ItemStack.new(ItemStack.ItemType.Rock, 3)
	]},
	{"result": ItemStack.new(ItemStack.ItemType.Rock), "ingredients": [
		ItemStack.new(ItemStack.ItemType.Wood, 1),
	]},
]

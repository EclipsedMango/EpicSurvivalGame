class_name Recipes
extends RefCounted

static var recipes: Array = [
	{"result": ItemStack.new(ItemStack.ItemType.Pickaxe), "ingredients": [
		ItemStack.new(ItemStack.ItemType.Wood, 5), 
		ItemStack.new(ItemStack.ItemType.Rock, 3)
	]},
	{"result": ItemStack.new(ItemStack.ItemType.Axe), "ingredients": [
		ItemStack.new(ItemStack.ItemType.Wood, 4),
		ItemStack.new(ItemStack.ItemType.Rock, 4)
	]},
]

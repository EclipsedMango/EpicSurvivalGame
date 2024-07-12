extends Control

@onready var inventory: Inventory = $"../.."
@onready var recipe_container: Control = %RecipeContainer

var ui_recipe_res = preload("res://Scenes/ui_recipe.tscn")
var ui_ingredient_res = preload("res://Scenes/ui_ingredient_stack.tscn")

func _ready() -> void:
	_inv_updated()
	inventory.inv_updated.connect(_inv_updated)

func _inv_updated() -> void:
	for child in recipe_container.get_children():
		child.queue_free()
	
	for recipe: Dictionary in Recipes.recipes:
		if _has_items(recipe):
			var ui_recipe: Control = ui_recipe_res.instantiate()
			var ui_result = ui_recipe.get_node("UiResult")
			inventory._update_ui_item(ui_result, recipe.result)
			ui_result.get_node("Button").pressed.connect(_recipe_pressed.bind(recipe))
			
			var ingredient_container = ui_recipe.get_node("IngredientContainer")
			
			for ingredient: ItemStack in recipe.ingredients:
				var ui_ingredient: Control = ui_ingredient_res.instantiate()
				inventory._update_ui_item(ui_ingredient, ingredient)
				ingredient_container.add_child(ui_ingredient)
			
			recipe_container.add_child(ui_recipe)

func _recipe_pressed(recipe: Dictionary) -> void:
	if inventory.cursor_item != null:
		return
	
	inventory.cursor_item = ItemStack.new(recipe.result.type, recipe.result.amount)
	inventory._update_ui_item(inventory.ui_cursor_item, inventory.cursor_item)
	for ingredient: ItemStack in recipe.ingredients:
		inventory.remove_items(ingredient.type, ingredient.amount)

func _has_items(recipe: Dictionary) -> bool:
	for ingredient: ItemStack in recipe.ingredients:
		if inventory.count_items(ingredient.type, ingredient.amount) < ingredient.amount:
			return false
	
	return true

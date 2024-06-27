class_name Inventory
extends Control 

@onready var grid_container: GridContainer = $Control/GridContainer
@onready var grid_container_2: GridContainer = $Control/GridContainer2
@onready var ui_cursor_item: MarginContainer = $Control/CursorItem

const inv_size: int = 36
var items: Array = []
var cursor_item: ItemStack = null
var selected_slot: int = 0

func _ready() -> void:
	for i in range(inv_size):
		items.append(null)
	
	items[0] = ItemStack.new(ItemStack.ItemType.Pickaxe)
	
	for i in range(inv_size):
		var ui_item = _get_ui_item(i)
		var item_button: Button = ui_item.get_node("Button")
		
		item_button.pressed.connect(clicked_item.bind(i))
		
		_update_ui_item(ui_item, items[i])
	
	_update_ui_item(ui_cursor_item, cursor_item)

func _process(delta: float) -> void:
	ui_cursor_item.global_position = get_global_mouse_position() - Vector2.ONE * 50
	
	if Input.is_action_just_pressed("next_item"):
		selected_slot = (selected_slot + 1) % 9
	
	if Input.is_action_just_pressed("previous_item"):
		selected_slot = (selected_slot + 8) % 9
	
	for i in range(9):
		if Input.is_action_just_pressed("select_slot_" + str(i + 1)):
			selected_slot = i

func _get_ui_item(index: int) -> Control:
	if index > 26:
		return grid_container_2.get_child(index - 27)
	
	return grid_container.get_child(index)

func clicked_item(index: int) -> void:
	var temp = cursor_item
	cursor_item = items[index]
	items[index] = temp
	
	var ui_item = _get_ui_item(index)
	
	_update_ui_item(ui_item, items[index])
	_update_ui_item(ui_cursor_item, cursor_item)

func _update_ui_item(ui_item: Node, item: ItemStack) -> void:
	var item_label: Label = ui_item.get_node("ItemCount")
	
	if item == null:
		item_label.text = ""
		return
	
	item_label.text = ItemStack.type_names[item.type]

func get_held_item() -> ItemStack:
	return items[selected_slot + 27]

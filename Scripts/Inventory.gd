class_name Inventory
extends Control 

@onready var grid_container: GridContainer = %InventoryGrid
@onready var grid_container_2: GridContainer = %InventoryHotbarGrid
@onready var ui_cursor_item: MarginContainer = %CursorItem
@onready var hotbar: Control = %Hotbar
@onready var menu: Control = $CenterContainer
@onready var hotbar_grid: GridContainer = %HotbarGrid
@onready var highlight: Panel = %Highlight

const inv_size: int = 36
var items: Array = []
var cursor_item: ItemStack = null
var selected_slot: int = 0

func _ready() -> void:
	for i in range(27, 36):
		var ui_item = _get_ui_hotbar_item(i)
		ui_item.get_node("Button").queue_free()
	
	ui_cursor_item.get_node("Button").queue_free()
	
	for i in range(inv_size):
		items.append(null)
	
	items[0] = ItemStack.new(ItemStack.ItemType.Pickaxe)
	
	for i in range(inv_size):
		var ui_item = _get_ui_item(i)
		var item_button: Button = ui_item.get_node("Button")
		
		item_button.pressed.connect(clicked_item.bind(i))
		
		_update_ui_item(ui_item, items[i])
		
		if i > 26:
			var hotbar_item = _get_ui_hotbar_item(i)
			_update_ui_item(hotbar_item, items[i])
	
	_update_ui_item(ui_cursor_item, cursor_item)

func _process(delta: float) -> void:
	ui_cursor_item.global_position = get_global_mouse_position() - Vector2.ONE * 50
	
	if Input.is_action_just_pressed("next_item"):
		selected_slot = (selected_slot + 1) % 9
		_update_highlighted()
	
	if Input.is_action_just_pressed("previous_item"):
		selected_slot = (selected_slot + 8) % 9
		_update_highlighted()
	
	for i in range(9):
		if Input.is_action_just_pressed("select_slot_" + str(i + 1)):
			selected_slot = i
			_update_highlighted()

func _update_highlighted() -> void:
	highlight.position.x = 86.375 * selected_slot

func _get_ui_item(index: int) -> Control:
	if index > 26:
		return grid_container_2.get_child(index - 27)
	
	return grid_container.get_child(index)

func _get_ui_hotbar_item(index: int) -> Control:
	return hotbar_grid.get_child(index - 27)

func clicked_item(index: int) -> void:
	if cursor_item != null && items[index] != null && _try_merge_stack(items[index], cursor_item):
		cursor_item = null
	else:
		_swap_with_cursor(index)
	
	var ui_item = _get_ui_item(index)
	
	_update_ui_slot(index, items[index])
	_update_ui_item(ui_cursor_item, cursor_item)

func _update_ui_slot(index: int, item: ItemStack) -> void:
	_update_ui_item(_get_ui_item(index), item)
	
	if index > 26:
		var hotbar_item = _get_ui_hotbar_item(index)
		_update_ui_item(hotbar_item, items[index])

func _update_ui_item(ui_item: Node, item: ItemStack) -> void:
	var item_label: Label = ui_item.get_node("ItemName")
	var item_count: Label = ui_item.get_node("ItemCount")
	
	if item == null:
		item_label.text = ""
		item_count.text = ""
		return
	
	item_label.text = ItemStack.type_names[item.type]
	item_count.text = str(item.amount)

func get_held_item() -> ItemStack:
	return items[selected_slot + 27]

func set_opened(open: bool) -> void:
	menu.visible = open
	hotbar.visible = !open

func is_opened() -> bool:
	return menu.visible

func add_item(item: ItemStack) -> bool:
	for i in range(inv_size):
		if items[i] != null && items[i].type == item.type:
			_try_merge_stack(items[i], item)
			_update_ui_slot(i, items[i])
			return true
	
	for i in range(inv_size):
		if items[i] == null:
			items[i] = item
			_update_ui_slot(i, items[i])
			return true
	
	return false

func _try_merge_stack(item1: ItemStack, item2: ItemStack) -> bool:
	if item1.type == item2.type:
		item1.amount += item2.amount
		return true
	
	return false

func _swap_with_cursor(index: int) -> void:
	var temp = cursor_item
	cursor_item = items[index]
	items[index] = temp

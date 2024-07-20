class_name Inventory
extends Control 

signal inv_updated

@onready var grid_container: GridContainer = %InventoryGrid
@onready var grid_container_2: GridContainer = %InventoryHotbarGrid
@onready var ui_cursor_item: MarginContainer = %CursorItem
@onready var hotbar: Control = %Hotbar
@onready var menu: Control = $Menu
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
	items[1] = ItemStack.new(ItemStack.ItemType.Axe)
	
	for i in range(inv_size):
		var ui_item = _get_ui_item(i)
		var item_button: Button = ui_item.get_node("Button")
		
		#item_button.pressed.connect(clicked_item.bind(i))
		item_button.gui_input.connect(_ui_item_gui_input.bind(i))
		
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
	highlight.position.x = 104.75 * selected_slot

func _get_ui_item(index: int) -> Control:
	if index > 26:
		return grid_container_2.get_child(index - 27)
	
	return grid_container.get_child(index)

func _get_ui_hotbar_item(index: int) -> Control:
	return hotbar_grid.get_child(index - 27)

func _ui_item_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_clicked_item(index)
			MOUSE_BUTTON_RIGHT:
				_right_clicked_item(index)

func _clicked_item(index: int) -> void:
	if Input.is_action_pressed("fast"):
		var item: ItemStack = items[index]
		if item == null:
			return
		
		if index > 26:
			items[index] = null
			add_item(item)
			_update_ui_slot(index)
			inv_updated.emit()
			return
		
		if add_item(item, 27):
			items[index] = null
			_update_ui_slot(index)
			inv_updated.emit()
		
		return
	
	if cursor_item != null && _try_merge_stack(items[index], cursor_item):
		cursor_item = null
	else:
		_swap_with_cursor(index)
	
	_update_ui_slot(index)
	_update_ui_item(ui_cursor_item, cursor_item)
	inv_updated.emit()

func _right_clicked_item(index: int) -> void:
	_try_split_stack(index)
	inv_updated.emit()

func _update_ui_slot(index: int) -> void:
	_update_ui_item(_get_ui_item(index), items[index])
	
	if index > 26:
		var hotbar_item = _get_ui_hotbar_item(index)
		_update_ui_item(hotbar_item, items[index])

func _update_ui_item(ui_item: Node, item: ItemStack) -> void:
	#var item_label: Label = ui_item.get_node("ItemName")
	var item_count: Label = ui_item.get_node("ItemCount")
	var texture_rect: TextureRect = ui_item.get_node("TextureRect")
	
	if item == null:
		#item_label.text = ""
		item_count.text = ""
		texture_rect.visible = false
		return
	
	#item_label.text = ItemStack.type_names[item.type]
	item_count.text = str(item.amount)
	texture_rect.visible = true
	texture_rect.texture = ItemStack.type_icons[item.type]

func get_held_item() -> ItemStack:
	return items[selected_slot + 27]

func set_opened(open: bool) -> void:
	menu.visible = open
	hotbar.visible = !open

func is_opened() -> bool:
	return menu.visible

func add_item(item: ItemStack, start_index: int = 0) -> bool:
	var slot: int = _find_first_slot(item.type, start_index)
	if slot == -1:
		return false
	
	if !_try_merge_stack(items[slot], item):
		items[slot] = item
	
	_update_ui_slot(slot)
	
	inv_updated.emit()
	return true

func _find_first_slot(type: ItemStack.ItemType, start_index: int = 0) -> int:
	for i in range(start_index, inv_size):
		if items[i] != null && items[i].type == type:
			return i
	
	for i in range(start_index, inv_size):
		if items[i] == null:
			return i
	
	return -1

func _try_merge_stack(item1: ItemStack, item2: ItemStack) -> bool:
	if item1 != null && item1.type == item2.type:
		item1.amount += item2.amount
		return true
	
	return false

func _try_split_stack(index: int) -> bool:
	var item: ItemStack = items[index]
	if item != null && cursor_item == null && item.amount > 1:
		var odd_num = item.amount % 2
		item.amount /= 2
		if odd_num:
			cursor_item = ItemStack.new(item.type, item.amount + 1)
		else:
			cursor_item = ItemStack.new(item.type, item.amount)
		_update_ui_slot(index)
		_update_ui_item(ui_cursor_item, cursor_item)
		return true
	
	if item != null && cursor_item == null && item.amount == 1:
		_swap_with_cursor(index)
		_update_ui_slot(index)
		_update_ui_item(ui_cursor_item, cursor_item)
	
	return false

func _swap_with_cursor(index: int) -> void:
	var temp = cursor_item
	cursor_item = items[index]
	items[index] = temp

func count_items(type: ItemStack.ItemType, max_count: int) -> int:
	var count: int = 0
	for item in items:
		if item != null && item.type == type:
			count += item.amount
			if count >= max_count:
				return count
	return count

func remove_items(type: ItemStack.ItemType, amount: int) -> void:
	for i in range(inv_size):
		if items[i] != null && items[i].type == type:
			if items[i].amount < amount:
				amount -= items[i].amount
				items[i] = null
				_update_ui_slot(i)
				continue
			
			items[i].amount -= amount
			if items[i].amount == 0:
				items[i] = null
			_update_ui_slot(i)
			inv_updated.emit()
			return
	printerr("failed to remove items. how the fuck did you get here?")
	inv_updated.emit()

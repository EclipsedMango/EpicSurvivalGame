extends Camera3D

@onready var fps_rig: Node3D = $FpsRig
@onready var animation_player_pickaxe: AnimationPlayer = $FpsRig/Pickaxe/pickaxe/AnimationPlayer
@onready var animation_player_axe: AnimationPlayer = $FpsRig/Axe/axe/AnimationPlayer
@onready var inventory: Inventory = $"../../../../../Inventory"

var pickaxe_in_use: bool = true
var axe_in_use: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var holding_pickaxe := inventory.get_held_item() != null && inventory.get_held_item().type == ItemStack.ItemType.Pickaxe
	if holding_pickaxe != pickaxe_in_use:
		pickaxe_in_use = !pickaxe_in_use
		if pickaxe_in_use:
			animation_player_pickaxe.play("PullOut")
		else:
			animation_player_pickaxe.play("PutAway")
	
	var holding_axe := inventory.get_held_item() != null && inventory.get_held_item().type == ItemStack.ItemType.Axe
	if holding_axe != axe_in_use:
		axe_in_use = !axe_in_use
		if axe_in_use:
			animation_player_axe.play("PullOut")
		else:
			animation_player_axe.play("PutAway")
	
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta * 5.0)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta * 5.0)

func sway(sway_amount_x, sway_amount_y) -> void:
	fps_rig.position.x += abs(sway_amount_x * 0.00005)
	fps_rig.position.y += abs(sway_amount_y * 0.00005)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") && inventory.get_held_item() != null && inventory.get_held_item().type == ItemStack.ItemType.Pickaxe:
		animation_player_pickaxe.play("Swing")
	
	if event.is_action_pressed("attack") && inventory.get_held_item() != null && inventory.get_held_item().type == ItemStack.ItemType.Axe:
		animation_player_axe.play("Swing")

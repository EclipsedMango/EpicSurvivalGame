extends Camera3D

@onready var fps_rig: Node3D = $FpsRig
@onready var animation_player: AnimationPlayer = $FpsRig/Pickaxe/pickaxe/AnimationPlayer
@onready var inventory: Inventory = $"../../../../../Inventory"

var pick_axe_in_use: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if inventory.get_held_item() != null && inventory.get_held_item().type == ItemStack.ItemType.Pickaxe:
		pick_axe_in_use = !pick_axe_in_use
		if pick_axe_in_use:
			animation_player.play("PutAway")
		else:
			animation_player.play("PullOut")
	
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta * 5.0)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta * 5.0)

func sway(sway_amount_x, sway_amount_y) -> void:
	fps_rig.position.x += abs(sway_amount_x * 0.00005)
	fps_rig.position.y += abs(sway_amount_y * 0.00005)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		animation_player.play("Swing")
	
	

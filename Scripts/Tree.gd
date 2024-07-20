extends StaticBody3D

var dropped_item_res: PackedScene = preload("res://Scenes/dropped_item.tscn")

@onready var model: Node3D = $Tree4REFINED
@onready var mesh: MeshInstance3D = $Tree4REFINED/tree

@onready var original_color: Color = mesh.material_override.albedo_color

const INVULNERABLE_TIMER: float = 0.4

var health: float = 5.0
var basic_damage: float = 1.0
var invulnerable: bool = false

func _ready() -> void:
	mesh.material_override = mesh.material_override.duplicate()

func _process(delta: float) -> void:
	model.visible = get_viewport().get_camera_3d().global_position.distance_to(global_position) < 20

func damage(damager: Variant, damage_amount: float):
	if !damager is Player:
		return
	
	if damager.inventory.get_held_item() == null \
			|| damager.inventory.get_held_item().type != ItemStack.ItemType.Axe:
		return
	
	if invulnerable:
		return
	
	health -= damage_amount
	invulnerable = true
	if health <= 0.0:
		queue_free()
		var dropped_item: DroppedItem = dropped_item_res.instantiate()
		dropped_item.item = ItemStack.new(ItemStack.ItemType.Wood, int((scale.x - 1.25) * 6 + 1))
		get_parent().get_parent().add_child(dropped_item)
		dropped_item.global_position = global_position + Vector3(0, 1.0, 0)
	
	mesh.material_override.albedo_color = Color.BROWN
	get_tree().create_timer(INVULNERABLE_TIMER).timeout.connect(func():
		invulnerable = false
		get_tree().create_timer(0.2).timeout.connect(func():
			mesh.material_override.albedo_color = original_color
			)
	)
	

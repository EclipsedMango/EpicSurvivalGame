extends StaticBody3D

var dropped_item_res: PackedScene = preload("res://Scenes/dropped_item.tscn")

@onready var model: Node3D = $Model
@onready var mesh: MeshInstance3D = $Model/tree

@onready var original_color: Color

const INVULNERABLE_TIMER: float = 0.15

var health: float = 5.0
var basic_damage: float = 1.0
var invulnerable: bool = false

func _ready() -> void:
	mesh.mesh.surface_set_material(0, mesh.mesh.surface_get_material(0).duplicate())
	original_color = mesh.mesh.surface_get_material(0).albedo_color

func _process(delta: float) -> void:
	model.visible = get_viewport().get_camera_3d().global_position.distance_to(global_position) < 20

func damage(damager: Variant, damage_amount: float):
	if invulnerable:
		return
	
	health -= damage_amount
	invulnerable = true
	if health <= 0.0:
		queue_free()
		var dropped_item: DroppedItem = dropped_item_res.instantiate()
		dropped_item.item = ItemStack.new(ItemStack.ItemType.Wood)
		get_parent().get_parent().add_child(dropped_item)
		dropped_item.global_position = global_position + Vector3(0, 0.5, 0)
	
	mesh.mesh.surface_get_material(0).albedo_color = Color.BROWN
	get_tree().create_timer(INVULNERABLE_TIMER).timeout.connect(func():
		invulnerable = false
		mesh.mesh.surface_get_material(0).albedo_color = original_color
	)
	

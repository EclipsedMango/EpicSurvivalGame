extends StaticBody3D

var dropped_item_res: PackedScene = preload("res://Scenes/dropped_item.tscn")

@onready var damage_zone: Area3D = $DamageZone
@onready var mesh: MeshInstance3D = $MeshInstance3D

@onready var original_color: Color = mesh.material_override.albedo_color

const INVULNERABLE_TIMER: float = 0.4

var rock_health: float = 5.0
var basic_damage: float = 1.0
var invulnerable: bool = false

func _ready() -> void:
	mesh.material_override = mesh.material_override.duplicate()

func _physics_process(delta):
	for body in damage_zone.get_overlapping_bodies():
		if body.has_method("damage_player"):
			body.damage_player(self, 1.0)

func damage(damager: Variant, damage_amount: float):
	if !damager is Player:
		return
	
	if damager.inventory.get_held_item() == null \
			|| damager.inventory.get_held_item().type != ItemStack.ItemType.Pickaxe:
		return
	
	if invulnerable:
		return
	
	rock_health -= damage_amount
	invulnerable = true
	if rock_health <= 0.0:
		queue_free()
		var dropped_item: DroppedItem = dropped_item_res.instantiate()
		dropped_item.item = ItemStack.new(ItemStack.ItemType.Rock, int((scale.x - 0.5) * 10 + 1))
		get_parent().get_parent().add_child(dropped_item)
		dropped_item.global_position = global_position + Vector3(0, 1.0, 0)
	
	mesh.material_override.albedo_color = Color.BROWN
	get_tree().create_timer(INVULNERABLE_TIMER).timeout.connect(func():
		invulnerable = false
		mesh.material_override.albedo_color = original_color
	)

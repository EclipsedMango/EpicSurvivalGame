extends StaticBody3D

@onready var damage_zone: Area3D = $DamageZone
@onready var mesh: MeshInstance3D = $MeshInstance3D

const INVULNERABLE_TIMER: float = 0.15

var rock_health: float = 5.0
var basic_damage: float = 1.0
var invulnerable: bool = false

func _physics_process(delta):
	for body in damage_zone.get_overlapping_bodies():
		if body.has_method("damage_player"):
			body.damage_player()

func damage():
	rock_health -= basic_damage
	invulnerable = true
	if rock_health <= 0.0:
		queue_free()
	
	mesh.material_override.albedo_color = Color.RED
	get_tree().create_timer(INVULNERABLE_TIMER).timeout.connect(func():
		invulnerable = false
		mesh.material_override.albedo_color = Color.WHITE
	)
	

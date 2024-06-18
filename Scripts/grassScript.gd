extends GPUParticles3D

@onready var player = $"/root/World/PlayerRelated/Player"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(player):
		player = $"/root/World/PlayerRelated/Player"
	
	global_position = player.global_position

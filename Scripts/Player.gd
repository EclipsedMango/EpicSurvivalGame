class_name Player
extends CharacterBody3D

const SPEED: float = 20.5
const JUMP_VELOCITY: float = 40.5 / 2
const MOUSE_SENSITIVITY: float = 0.001
const LOOK_LIMIT: float = PI / 2
const RAY_LENGTH: int = 1000
const JUMP_LIMIT: int = 1000
const INVULNERABLE_TIMER: float = 0.15

var jumps: int = 0
var health: float = 20.0
var invulnerable: bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_res: PackedScene = load("res://Scenes/player.tscn")

@onready var head: Node3D = $Head
@onready var reach: Node3D = $Head/Reach
@onready var health_label: Label = $PlayerHealth
@onready var pause_menu: Control = $PauseMenu
@onready var respawn_menu: Control = $RespawnMenu
@onready var inventory: Inventory = $Inventory

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	pause_menu.visible = false
	respawn_menu.visible = false
	inventory.visible = true
	inventory.set_opened(false)


func _physics_process(delta) -> void:
	if is_menu_open():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else: 
		jumps = 0

	# Handle jump.
	if is_just_pressed("jump") and jumps < JUMP_LIMIT:
		jumps += 1;
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	if is_menu_open():
		input_dir = Vector2()

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var slow: bool = is_held("slow")
	var fast: bool = is_held("fast")
	
	# slower than walking.
	if slow:
		direction *= 0.5
	
	# Running/Sprinting.
	if fast:
		direction *= 2.0
	
	# vec2 velocity and direction.
	var vel := Vector2(velocity.x, velocity.z)
	var dir := Vector2(direction.x, direction.z)
	
	# making acceleration but only for sprinting.
	if direction:
		vel = dir * SPEED
	else:
		vel = vel.move_toward(Vector2.ZERO, SPEED)
	
	#if direction:
		#if not fast:
			#vel = dir * SPEED
		#else:
			#vel = vel.move_toward(dir * SPEED, 9 * delta)
	#else:
		#if not fast:
			#vel = dir * SPEED
		#else:
			#vel = vel.move_toward(Vector2.ZERO, 20 * delta)
	
	# resetting velocity
	velocity.x = vel.x
	velocity.z = vel.y

	health_label.text = str("Speed: ", vel.length(), "\nVel: ", velocity, "\nHealth: ", health)

	if is_just_pressed("attack"):
		var origin: Vector3 = head.global_position
		var end: Vector3 = reach.global_position
		var query := PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = false
		var result: Dictionary = space_state.intersect_ray(query)
		
		if result.has("collider") && result.collider.has_method("damage") \
				&& inventory.get_held_item() != null \
				&& inventory.get_held_item().type == ItemStack.ItemType.Pickaxe:
			result.collider.damage(self, 1.0)

	# Player Death.
	if health <= 0:
		respawn_menu.visible = true
		pause_menu.visible = false
		inventory.set_opened(false)
		inventory.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Pause Menu.
	if Input.is_action_just_pressed("pause") && !inventory.is_opened() && !respawn_menu.visible:
		pause_menu.visible = !pause_menu.visible
		if pause_menu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Inventory Menu.
	if (Input.is_action_just_pressed("open_inventory") || Input.is_action_just_pressed("pause")) && !pause_menu.visible && !respawn_menu.visible:
		if inventory.is_opened():
			inventory.set_opened(false)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.is_action_just_pressed("open_inventory"):
			inventory.set_opened(true)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	move_and_slide()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !is_menu_open():
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		head.rotation.x = clampf(head.rotation.x - (event.relative.y * MOUSE_SENSITIVITY), -LOOK_LIMIT, LOOK_LIMIT)
		velocity = velocity.rotated(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)

func damage_player(damager: Variant, damage_done: float) -> void:
	if invulnerable:
		return
	
	health -= damage_done
	invulnerable = true
	
	get_tree().create_timer(INVULNERABLE_TIMER).timeout.connect(func():
		invulnerable = false
	)


func respawn_player() -> void:
	name = "dead_player"
	queue_free()
	
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var new_player: Player = player_res.instantiate()
	new_player.name = "Player"
	
	get_parent().add_child(new_player)

func is_just_pressed(action: StringName) -> bool:
	return !is_menu_open() && Input.is_action_just_pressed(action)

func is_held(action: StringName) -> bool:
	return !is_menu_open() && Input.is_action_pressed(action)

func is_menu_open() -> bool:
	return pause_menu.visible || respawn_menu.visible || inventory.is_opened()

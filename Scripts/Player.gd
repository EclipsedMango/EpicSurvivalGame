class_name Player
extends CharacterBody3D

const SPEED = 2.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.001
const LOOK_LIMIT = PI / 2
const RAY_LENGTH = 1000

var JUMP_LIMIT: int = 1
var jumps: int = 0
var health = 10.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_res = load("res://Scenes/player.tscn")

@onready var head: Node3D = $Head
@onready var reach: Node3D = $Head/Reach
@onready var health_label: Label = $PlayerHealth
@onready var pause_menu: Control = $PauseMenu

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	pause_menu.visible = false


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else: 
		jumps = 0

	# Handle jump.
	if is_just_pressed("jump") and jumps < 2:
		jumps += 1;
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if pause_menu.visible:
		input_dir = Vector2()

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var slow = is_held("slow")
	var fast = is_held("fast")
	
	# slower than walking.
	if slow:
		direction *= 0.5
	
	# Running/Sprinting.
	if fast:
		direction *= 2.0
	
	# vec2 velocity and direction.
	var vel = Vector2(velocity.x, velocity.z)
	var dir = Vector2(direction.x, direction.z)
	
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

	health_label.text = str("Speed: ", vel.length(), "\nVel: ", velocity)

	if is_just_pressed("attack"):
		var origin = head.global_position
		var end = reach.global_position
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = false
		var result = space_state.intersect_ray(query)
		
		if result.has("collider") and result.collider.has_method("damage"):
			result.collider.damage()

	if health == 0:
		queue_free()
		
		var new_player = player_res.instantiate()
		get_parent().add_child(new_player)

	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = not pause_menu.visible
		if pause_menu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	move_and_slide()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not pause_menu.visible:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		head.rotation.x = clampf(head.rotation.x - (event.relative.y * MOUSE_SENSITIVITY), -LOOK_LIMIT, LOOK_LIMIT)
		velocity = velocity.rotated(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)

func damage_player():
	health -= 1.0
	health_label.text = "health: " + str(health)

func is_just_pressed(action: StringName):
	return not pause_menu.visible and Input.is_action_just_pressed(action)

func is_held(action: StringName):
	return not pause_menu.visible and Input.is_action_pressed(action)

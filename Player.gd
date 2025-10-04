extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.03
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@export var head: Node3D
@export var collision: CollisionShape3D
@export var mesh: MeshInstance3D
@export var camera: Camera3D

var speed
var t_bob = 0.0
var is_crouching = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_crouching:
		velocity.y = JUMP_VELOCITY
		
	# Crouch
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		is_crouching = !is_crouching
		if is_crouching:
			collision.scale.y = 0.5
			collision.position.y = 0.5
			mesh.scale.y = 0.5
			mesh.position.y = 0.5
			head.position.y = 0.75
		else:
			collision.scale.y = 1.0
			collision.position.y = 1.0
			mesh.scale.y = 1.0
			mesh.position.y = 1.0
			head.position.y = 1.5

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	speed = WALK_SPEED
	if Input.is_action_pressed("sprint") and !is_crouching:
		speed = SPRINT_SPEED
	elif is_crouching:
		speed = CROUCH_SPEED
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			#velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			#velocity.y = lerp(velocity.y, direction.y * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.y = lerp(velocity.y, direction.y * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

extends KinematicBody

# Viewing constants
const MOUSE_SENS_X := -0.01
const MOUSE_SENS_Y := -0.01
const MIN_CAM_ANGLE = -85
const MAX_CAM_ANGLE = 85

# Moving constants
const MAX_SPEED = 8
const MAX_SPEED_SPRINT = 12
const ACCELERATION = 4
const DECCELERATION = 8
const JUMP_SPEED = 10

# References to nodes 
onready var head: Spatial = $Head
onready var raycast: RayCast = $Head/Camera/RayCast

# Settings
onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")

# Variables
var velocity: Vector3 = Vector3(0, 0, 0)


# Override functions

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float):
	handle_movement(delta)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		handle_mouse_rotation(event)

	if Input.is_action_pressed("primary"):
		handle_shooting()

	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Custom functions

func handle_shooting():
	var collider = raycast.get_collider()
	print(collider)


func handle_mouse_rotation(event) -> void:
	rotate_y(MOUSE_SENS_X * event.relative.x)
	head.rotate_x(MOUSE_SENS_Y * event.relative.y)
	head.rotation.x = clamp(
		head.rotation.x,
		deg2rad(MIN_CAM_ANGLE),
		deg2rad(MAX_CAM_ANGLE)
	)


func get_action_strength_vector() -> Vector3:
	return Vector3(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		0,
		Input.get_action_strength("backward") - Input.get_action_strength("forward")
	)


func get_target_speed():
	if Input.is_action_pressed("sprint"):
		return MAX_SPEED_SPRINT
	else:
		return MAX_SPEED


func handle_movement(delta: float):
	var dir := get_action_strength_vector()
	
	dir = global_transform.basis.xform(dir)

	if dir.length_squared() > 1:
		dir /= dir.length()

	velocity.y += delta * gravity

	var hvel := Vector3(velocity.x, 0, velocity.z)
	var target_velocity = dir * get_target_speed()
	var accel = ACCELERATION if target_velocity.dot(hvel) > 0 else DECCELERATION

	hvel = hvel.linear_interpolate(target_velocity, accel * delta)

	velocity = Vector3(hvel.x, velocity.y, hvel.z)

	velocity = move_and_slide(velocity, Vector3.UP)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED

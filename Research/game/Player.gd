extends KinematicBody

const MOUSE_SENS_X := -0.01
const MOUSE_SENS_Y := -0.01
const MIN_CAM_ANGLE = -85
const MAX_CAM_ANGLE = 85

const MAX_SPEED = 12
const MAX_SPEED_SPRINT = 26
const ACCELERATION = 6
const DECCELERATION = 8
const JUMP_SPEED = 20

onready var head: Spatial = $Head

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity: Vector3 = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
#  func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(MOUSE_SENS_X * event.relative.x)
		head.rotate_x(MOUSE_SENS_Y * event.relative.y)
		head.rotation.x = clamp(
			head.rotation.x,
			deg2rad(MIN_CAM_ANGLE),
			deg2rad(MAX_CAM_ANGLE)
		)

func _physics_process(delta: float):
	process_movement(delta)

func process_movement(delta: float):
	var dir := Vector3()
	dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	dir.z = Input.get_action_strength("back") - Input.get_action_strength("forward")

	dir = global_transform.basis.xform(dir)

	if dir.length_squared() > 1:
		dir /= dir.length()

	velocity.y += delta * gravity

	var hvel := velocity
	hvel.y = 0

	var target_speed = MAX_SPEED_SPRINT if Input.is_action_pressed("sprint") else MAX_SPEED
	var target_velocity = dir * target_speed
	var accel = ACCELERATION if target_velocity.dot(hvel) > 0 else DECCELERATION

	hvel = hvel.linear_interpolate(target_velocity, accel * delta)

	velocity.x = hvel.x
	velocity.z = hvel.z

	velocity = move_and_slide(velocity, Vector3.UP)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED

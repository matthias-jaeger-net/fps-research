extends KinematicBody

onready var head: Spatial = $Head
onready var raycast: RayCast = $Head/Camera/RayCast
onready var camera: Camera = $Head/Camera
onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
onready var pistol = $Head/Camera/Hand/pistol
onready var rifle = $Head/Camera/Hand/rifle
onready var weapons = [pistol, rifle]
onready var anim = $AnimationPlayer

var current_weapon

func hide_weapons():
	for weapon in weapons:
		weapon.visible = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float):
	handle_movement(delta)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		handle_mouse_rotation(event)

	if Input.is_action_pressed("primary"):
		handle_shooting()
		if (current_weapon == "rifle"):
			anim.play("shoot_rifle")
		else: 
			anim.play("fire")
	else: 
		anim.stop()

	# TODO - fix aiming plus shooting
	if Input.is_action_pressed("aim"):
		anim.play("aim")
 
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("pistol"):
		hide_weapons()
		pistol.visible = true
		current_weapon = "pistol"

	if Input.is_action_just_pressed("rifle"):
		hide_weapons()
		rifle.visible = true
		current_weapon = "rifle"

func handle_shooting():
	var collider = raycast.get_collider()
	print(collider)
	if (collider != null):
		if (collider.get_class() == "StaticBody"):
			print("Hit target")
			collider.queue_free()


func handle_mouse_rotation(event) -> void:
	var MOUSE_SENS_X = -0.01
	var MOUSE_SENS_Y = -0.01
	# Look left-right
	rotate_y(MOUSE_SENS_X * event.relative.x)
	# Look up-down
	head.rotate_x(MOUSE_SENS_Y * event.relative.y)
	# Limit up-down looking
	head.rotation.x = clamp(
		head.rotation.x,
		deg2rad(-85),
		deg2rad(80)
	)


func get_action_strength_vector() -> Vector3:
	var r = Input.get_action_strength("right")
	var l = Input.get_action_strength("left")
	var f = Input.get_action_strength("forward")
	var b = Input.get_action_strength("backward")
	return Vector3(r - l, 0, b - f)


var velocity: Vector3 = Vector3(0, 0, 0)

func handle_movement(delta: float):
	# Moving constants
	var ACCELERATION = 4
	var DECCELERATION = 8
	var JUMP_SPEED = 10
	var MAX_SPEED = 12
	var MAX_SPEED_SPRINT = 18
		
	var dir: Vector3 = get_action_strength_vector()	
	dir = global_transform.basis.xform(dir)


	if dir.length_squared() > 1:
		dir /= dir.length()

	velocity.y += delta * gravity
	
	var target_speed 
	if Input.is_action_pressed("sprint"):
		target_speed =  MAX_SPEED_SPRINT
	else:
		target_speed =  MAX_SPEED
		
	var hvel := Vector3(velocity.x, 0, velocity.z)
	var target_velocity = dir * target_speed
	
	var accel = ACCELERATION if target_velocity.dot(hvel) > 0 else DECCELERATION

	hvel = hvel.linear_interpolate(target_velocity, accel * delta)

	velocity = Vector3(hvel.x, velocity.y, hvel.z)

	velocity = move_and_slide(velocity, Vector3.UP)

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED

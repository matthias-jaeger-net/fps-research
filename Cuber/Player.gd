extends KinematicBody

export var SENSITITVIY: float = 0.05
export var ACCELERATION: float = 8
export var DECCELERATION: float = 4
export var JUMP_SPEED: float = 20
export var MAX_SPEED: float = 18
export var MAX_SPEED_SPRINT: float = 14
export var GRAVITY: float = -12
export var velocity: Vector3 = Vector3(0, 0, 0)

onready var head: Spatial = $Head
onready var camera: Camera = $Head/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float):
	handle_movement(delta)

func _input(event: InputEvent):
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_pressed("Reload"):
		get_tree().change_scene("res://StartScreen.tscn")
	


func _unhandled_input(event):
	var bounds = deg2rad(89)
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-SENSITITVIY * event.relative.x))
		head.rotate_x(deg2rad(-SENSITITVIY * event.relative.y))
		head.rotation.x = clamp(head.rotation.x, -bounds, bounds)

func handle_movement(delta: float):
	var r = Input.get_action_strength("right")
	var l = Input.get_action_strength("left")
	var f = Input.get_action_strength("forward")
	var b = Input.get_action_strength("backwards")
	var dir: Vector3 = Vector3(r - l, 0, b - f)
	
	dir = global_transform.basis.xform(dir)
	
	dir = dir.normalized()
	
	velocity.y += delta * GRAVITY
	
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

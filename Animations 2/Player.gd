extends KinematicBody

export var SENSITITVIY: float = 0.05
export var ACCELERATION: float = 4
export var DECCELERATION: float = 8
export var JUMP_SPEED: float = 10
export var MAX_SPEED: float = 12
export var MAX_SPEED_SPRINT: float = 18
export var GRAVITY: float = -10
export var velocity: Vector3 = Vector3(0, 0, 0)

export var ADS_LERP: float = 20
export var FOV: float = 70
export var ADS_FOV: float = 50
export var default_position: Vector3
export var ads_position: Vector3

export var head_path: NodePath
export var camera_path: NodePath
export var weapon_camera_path: NodePath
export var raycast_path: NodePath
export var hand_path: NodePath
export var animation_path: NodePath
export var audio_path: NodePath
export var targets_path: NodePath
export var pistol_path: NodePath 

onready var head: Spatial = get_node(head_path)
onready var camera: Camera = get_node(camera_path)
onready var weapon_camera: Camera = get_node(weapon_camera_path)
onready var raycast: RayCast = get_node(raycast_path)
onready var hand: Spatial = get_node(hand_path)
onready var animation_player: AnimationPlayer = get_node(animation_path)
onready var audio_player: AudioStreamPlayer3D = get_node(audio_path)
onready var pistol: MeshInstance = get_node(pistol_path)
onready var targets: Spatial = get_node(targets_path)

const pistol_sound_path = "res://9mm-pistol-shoot-short-reverb-7152.mp3"
var pistol_sound = preload(pistol_sound_path)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	audio_player.stream = pistol_sound
	pistol.visible = false


func _process(delta: float):
	weapon_camera.global_transform = camera.global_transform	
	handle_aim_down_sights(delta)


func _physics_process(delta: float):
	handle_movement(delta)


func _input(event: InputEvent):
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_pressed("ui_accept"):
		pistol.visible = true
	
	if Input.is_action_pressed("primary"):
		handle_shooting()


func _unhandled_input(event):
	handle_view(event)


func handle_aim_down_sights(delta: float):
	if Input.is_action_pressed("secondary"):
		hand.transform.origin = hand.transform.origin.linear_interpolate(
			ads_position, 
			ADS_LERP * delta
		)
		camera.fov = lerp(camera.fov, ADS_FOV, ADS_LERP * delta)
	else: 
		hand.transform.origin = hand.transform.origin.linear_interpolate(
			default_position, 
			ADS_LERP * delta
		)		
		camera.fov = lerp(camera.fov, FOV, ADS_LERP * delta)


func handle_view(event: InputEvent):
	var bounds = deg2rad(89)
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-SENSITITVIY * event.relative.x))
		head.rotate_x(deg2rad(-SENSITITVIY * event.relative.y))
		head.rotation.x = clamp(head.rotation.x, -bounds, bounds)


func handle_shooting():
	animation_player.play("fire")
	audio_player.play()	
	var collider = raycast.get_collider()
	print(collider)

	if (collider):
		if (collider.get_parent().name == "Targets"):
			collider.queue_free()
			animation_player.stop()

	var children = targets.get_children()
	if (children == []):
		print("Mission accomplished")


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

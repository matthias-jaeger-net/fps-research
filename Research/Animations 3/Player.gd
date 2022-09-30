extends KinematicBody

onready var head: Spatial = get_node("Head")

export var camera_path: NodePath
onready var camera: Camera = get_node(camera_path)

export var weapon_camera_path: NodePath
onready var weapon_camera: Camera = get_node(weapon_camera_path)

export var raycast_path: NodePath
onready var raycast: RayCast = get_node(raycast_path)

export var hand_path: NodePath
onready var hand: Spatial = get_node(hand_path)

onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var audio_player: AudioStreamPlayer3D = get_node("AudioStreamPlayer3D")
var pistol_sound = preload("res://9mm-pistol-shoot-short-reverb-7152.mp3")

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity: Vector3 = Vector3(0, 0, 0)

export var targets_path: NodePath
onready var targets: Spatial = get_node(targets_path)

onready var pistol = get_node("Head/Hand/Pistol")

var hit_counter: int = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	audio_player.stream = pistol_sound
	pistol.visible = false

func _process(delta):
	weapon_camera.global_transform = camera.global_transform

func _physics_process(delta: float):
	handle_movement(delta)

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		pistol.visible = true

	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_pressed("primary"):
		animation_player.play("fire")
		audio_player.play()
		print(hit_counter)
		var collider = raycast.get_collider()
		print(collider)
		var children = targets.get_children()
		if collider != null:
			if (collider.get_parent().name == "Targets"):
				collider.queue_free()
				animation_player.stop()
				
				if (children == []):
					print("Mission accomplished")
	



func _unhandled_input(event):
	var sensitivity = 0.05
	var max_rotation = deg2rad(89)
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-sensitivity * event.relative.x))
		head.rotate_x(deg2rad(-sensitivity * event.relative.y))
		head.rotation.x = clamp(head.rotation.x, -max_rotation, max_rotation)


func get_action_strength_vector() -> Vector3:
	var r = Input.get_action_strength("right")
	var l = Input.get_action_strength("left")
	var f = Input.get_action_strength("forward")
	var b = Input.get_action_strength("backwards")
	return Vector3(r - l, 0, b - f)


func handle_movement(delta: float):
	# Moving constants
	var ACCELERATION = 4
	var DECCELERATION = 8
	var JUMP_SPEED = 10
	var MAX_SPEED = 12
	var MAX_SPEED_SPRINT = 18
	
	var dir: Vector3 = get_action_strength_vector()	
	dir = global_transform.basis.xform(dir)
	dir = dir.normalized()
	
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

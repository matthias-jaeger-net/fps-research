extends Spatial

const ADS_LERP = 20
const FOV = 70
const ADS_FOV = 50

export var default_position: Vector3
export var ads_position: Vector3

export var camera_path: NodePath
onready var camera: Camera = get_node(camera_path)

func _ready():
	pass

func _process(delta):
	if Input.is_action_pressed("secondary"):
		transform.origin = transform.origin.linear_interpolate(
			ads_position, 
			ADS_LERP*delta
		)
		camera.fov = lerp(camera.fov, ADS_FOV, ADS_LERP * delta)
	else: 
		transform.origin = transform.origin.linear_interpolate(
			default_position, 
			ADS_LERP*delta
		)		
		camera.fov = lerp(camera.fov, FOV, ADS_LERP * delta)

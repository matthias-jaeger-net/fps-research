extends MeshInstance

const HEIGHT_SCALER: int = 1
const IMAGE_SCALER: int = 1

onready var collision_shape = $StaticBody/CollisionShape
onready	var height_map_shape = HeightMapShape.new()
onready	var image_buffer = Image.new()

func _ready() -> void:
	# Load heightmap image is hacky
	image_buffer.load("res://heightmap.exr")
	
	# why?
	image_buffer.convert(Image.FORMAT_RF)

	# Get values from loaded image
	var height_data: PoolByteArray = image_buffer.get_data()
	var image_width: int = image_buffer.get_width()
	var image_height: int = image_buffer.get_height()

	# Make sure the image has the same grid/dimensions
	image_buffer.resize(image_width * IMAGE_SCALER, image_height * IMAGE_SCALER)

	# Scale height data to same value as the shader produces
	for index in range(0, height_data.size()):
		height_data[index] *= HEIGHT_SCALER

	# Set up the height map with the scaled data
	height_map_shape.set_map_width(image_width * IMAGE_SCALER)
	height_map_shape.set_map_depth(image_height * IMAGE_SCALER)
	height_map_shape.set_map_data(height_data)

	# Use the shape for the collisions
	collision_shape.set_shape(height_map_shape)
	

# Terrain from a heightmap with collision
extends MeshInstance

## VARIABLES
onready var collision_shape = $StaticBody/CollisionShape
export var shape_scaler = 1
export var image_scaler = 0.25
export var height_scaler = 1

# Brute force converts PoolByteArray to PoolRealArray
func convert2(data: PoolByteArray) -> PoolRealArray:
	var arr = PoolRealArray()
	for index in range(0, data.size()):
		arr.append(float(data[index]))
	return arr


# Creates a image and loads heightmap in it
func create_image_buffer(url: String) -> Image:
	var img: Image = Image.new()
	img.load(url)
	img.convert(Image.FORMAT_RF)
	return img


# Creates a heightmap shape from the data of an image
func create_heightmap_shape(img: Image) -> HeightMapShape:
	var map_data: PoolByteArray = img.get_data()
	var map_width: int = img.get_width() * image_scaler
	var map_depth: int = img.get_height() * image_scaler
	var shape: HeightMapShape = HeightMapShape.new()

	for index in range(0, map_data.size()):
		map_data[index] *= height_scaler

	shape.set_map_width(map_width)
	shape.set_map_depth(map_depth)
	shape.set_map_data(convert2(map_data))

	return shape


func _ready() -> void:
	var img: Image = create_image_buffer("res://heightmap_resource.tres")
	var shape: HeightMapShape = create_heightmap_shape(img)
	collision_shape.set_shape(shape)

extends MeshInstance

onready var colision_shape = $StaticBody/CollisionShape 
onready var chunk_size = 10.0
onready var height_ratio = 1.0 
onready var size_ratio = 1.0


func _ready() -> void:
	var img = Image.new()
	var shape = HeightMapShape.new()
	var spb = StreamPeerBuffer.new()
	colision_shape.shape = shape
	set("shader_param/height_map_ratio", height_ratio)
	img.load("res://heightmap.exr")
	img.convert(Image.FORMAT_RF)
	img.resize(img.get_width() * size_ratio, img.get_height() * size_ratio)
	var data = img.get_data()
	
	for i in range(0, data.size()):
		data[i] *= height_ratio
		
	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	#shape.map_data = new PoolRealArray(data)

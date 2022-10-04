extends Spatial

onready var random: RandomNumberGenerator = RandomNumberGenerator.new()

func get_grid(steps: int, scale: Vector3) -> PoolVector3Array:
	var arr = PoolVector3Array()
	
	for u in range(-steps/2, steps/2):
		for v in range(-steps/2, steps/2):
				for w in range(-steps/2, steps/2):
					arr.append(Vector3(u * scale.x, v * scale.y, w * scale.z))
	
	return arr

func render_cell(position: Vector3, scale: Vector3, angle: float) -> void:
	var cell = StaticBody.new()
	cell.transform.origin = position
	cell.rotate_x(angle)
	self.add_child(cell)  
	
	var box = BoxShape.new()
	box.set_extents(scale * 0.5)
	
	var collision_shape = CollisionShape.new()
	collision_shape.set_shape(box)
	cell.add_child(collision_shape) 
	
	var cube = CubeMesh.new()
	cube.set_size(scale)
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.set_mesh(cube)
	
	cell.add_child(mesh_instance)  

func get_random_color() -> Color:
	var r = random.randf_range(0, 1)
	var g = random.randf_range(0, 1)
	var b = random.randf_range(0, 1)
	var a = 1.0
	return Color(r, g, b, a)

func render_light(position) -> void:
	var light = OmniLight.new()
	light.transform.origin = position
	light.set_param(Light.PARAM_RANGE, random.randf_range(20, 40))
	light.set_color(get_random_color())
	self.add_child(light)

func _ready() -> void:
	var wall = Vector3(20, 20, 2)
	var box = Vector3(20, 20, 20)
	var slab = Vector3(20, 2, 20)
	var angle = 20
	var grid = get_grid(16, box)
	for position in grid:
		match random.randi_range(0, 5):
			0:
				render_cell(position, wall, angle)
			1:
				render_cell(position, box, angle)
			2:
				render_cell(position, slab, angle)
			3:
				render_cell(position, wall, angle + 45)
			4:
				render_light(position)

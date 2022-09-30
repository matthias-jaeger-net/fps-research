extends MeshInstance
tool

func _ready():
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices = []
	var arr = PoolVector3Array()
	var d = 100
	var s = 10
	for i in range(-d, d, s):
		for j in range(-d, d, s):
			var n = noise.get_noise_2d(i, j)
			mesh_data.push_back(Vector3(i*s, n*s, i*s))
			
#	mesh_data[ArrayMesh.ARRAY_VERTEX] = PoolVector3Array(
#		[
#			Vector3(0, 0, 0),
#			Vector3(100, 0, 0),
#			Vector3(100, 100, 0),
#			Vector3(0, 100, 0)	
#		]
#	)
#	mesh_data[ArrayMesh.ARRAY_INDEX] = PoolIntArray(
#		[
#			0, 1, 2,
#			0, 2, 3
#		]
#	)
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, vertices)


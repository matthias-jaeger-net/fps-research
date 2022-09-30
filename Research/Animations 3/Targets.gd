extends Spatial

var children = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	print(children)


func _process(delta):
	pass

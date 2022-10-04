extends Spatial

export var player_path: NodePath

onready var player: KinematicBody = get_node(player_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player

extends Spatial

onready var anim = $AnimationPlayer
onready var gun = $Head/Camera/gun

func _ready():
	gun.visible = false


func _input(event):
	if Input.is_action_pressed("forward"):
		anim.play("walk")	
	
	if Input.is_action_pressed("ui_accept"):
		gun.visible = true
		anim.play("up")
	
	if Input.is_action_pressed("fire"):
		anim.play("fire")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var world = get_node("/root/World")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	world.startNextLevel()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

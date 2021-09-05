extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var type = PlayerProgression.Type.REPAIR
export var direction = PlayerProgression.Direction.POSITIVE
onready var world = get_node("/root/World")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	world.playerProgress.allocateHour(type, direction)
	world.updateLevelEndUI()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

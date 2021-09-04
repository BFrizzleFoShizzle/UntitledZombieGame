extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var scene_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	# dumb fix for undoing in-game pause
	get_tree().paused = false
	get_tree().change_scene(scene_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

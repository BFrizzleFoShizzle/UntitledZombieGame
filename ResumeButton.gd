extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var world = get_node("/root/World")

func _pressed():
	world.get_node("PauseMenu").visible = false
	world.unpause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

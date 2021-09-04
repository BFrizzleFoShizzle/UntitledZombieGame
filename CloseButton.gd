extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export(NodePath) var menuPath
onready var menu = get_node(menuPath)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	menu.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

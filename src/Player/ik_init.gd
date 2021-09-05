extends SkeletonIK


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var targetNodePath
onready var targetNode = get_node(targetNodePath)

# Called when the node enters the scene tree for the first time.
func _ready():
	start(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	target = targetNode.global_transform

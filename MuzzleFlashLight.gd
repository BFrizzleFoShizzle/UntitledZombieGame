extends OmniLight


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const flashTime = 0.05
var currFlashTime = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func flash():
	currFlashTime = flashTime
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		currFlashTime -= delta
		if currFlashTime <= 0.0:
			visible = false
	pass

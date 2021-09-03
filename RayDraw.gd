extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var queuedLines = []
var currLines = []

# true if no segments are drawn
var is_clear = true

var UpdateTimeDelta = 0.1
var currUpdateTime = 0.0

# queue drawing of ray next frame
func queue_ray(startPoint, endPoint):
	queuedLines.append([startPoint, endPoint])
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	var camera = get_viewport().get_camera()
	for line in currLines:
		print(line[1])
		print(camera.unproject_position(line[1]))
		draw_line(camera.unproject_position(line[0]), camera.unproject_position(line[1]), Color(1,0,0))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currUpdateTime += delta
	if currUpdateTime > UpdateTimeDelta:
		currUpdateTime -= UpdateTimeDelta
		
		currLines = queuedLines
		queuedLines = []
		if currLines.size() > 0:
			is_clear = false
			update()
		elif !is_clear:
			update()
			is_clear = true
	pass

extends ImmediateGeometry


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var queuedLines = []
var currLines = []

# true if no segments are drawn
var is_clear = true

var UpdateTimeDelta = 0.03
var currUpdateTime = 0.0

# queue drawing of ray next frame
func queue_ray(startPoint, endPoint):
	queuedLines.append([startPoint, endPoint])

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update():
	var camera = get_viewport().get_camera()
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	for line in currLines:
		add_vertex(line[0])
		add_vertex(line[1])
	end()
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

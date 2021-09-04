extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const StartFade = 1.0
const EndFade = 2.0
var currTime  = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate material
	get_node("Mesh").set_surface_material(0, get_node("Mesh").get_surface_material(0).duplicate())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currTime += delta
	if(currTime > EndFade):
		queue_free()
	if currTime > StartFade:
		var fadeVal = 1.0 - ((currTime - StartFade) / (EndFade - StartFade))
		get_node("Mesh").get_surface_material(0).albedo_color = Color(1.0,1.0,1.0,fadeVal)
	pass

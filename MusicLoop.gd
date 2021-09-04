extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#print(stream.loop_begin)
	# HACK value from import settings overrides the value in our scene, so we 
	# change it back here
	stream.loop_begin = 381405
	stream.loop_end = 1144216
	play(20.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

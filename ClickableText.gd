extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("meta_clicked", self, "meta_clicked"); 
	pass # Replace with function body.

func meta_clicked(meta): 
	OS.shell_open(meta);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

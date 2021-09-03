extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const speed = 2.0
var health = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_collide(Vector3(-speed * delta, 0.0, 0.0 ))
	pass

func take_damage(damage):
	health = max(0.0, health-damage)
	if health == 0.0:
		queue_free()

extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const maxSpeed = 2.0
const accel = 2000.0
var health = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# used to set max velocity
func _integrate_forces(state):
	if(state.linear_velocity.length() > maxSpeed):
		state.linear_velocity /= (state.linear_velocity.length() / maxSpeed)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move_and_collide(Vector3(-speed * delta, 0.0, 0.0 ))
	add_force(Vector3(-1.0, 0.0, 0.0) * delta * accel, Vector3(0,0,0))
	pass

func take_damage(damage):
	health = max(0.0, health-damage)
	if health == 0.0:
		queue_free()

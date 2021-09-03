extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const accel = 2000.0
const maxSpeed = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# used to set max velocity
func _integrate_forces(state):
	if(state.linear_velocity.length() > maxSpeed):
		state.linear_velocity /= (state.linear_velocity.length() / maxSpeed)
	pass

func get_input_direction():
	return Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0.0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#translate(get_input_direction() * delta * speed)
	if(linear_velocity.length() < maxSpeed):
		add_force(get_input_direction() * delta * accel, Vector3(0,0,0))
	pass

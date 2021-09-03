extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const accel = 2000.0
const maxSpeed = 3.0
var damage = 25.0

const Enemy = preload("res://Enemy.gd")


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

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index  == 1 && event.pressed == true:
			var rayOrigin = global_transform.origin + Vector3(0.0, 0.2, 0.0)
			
			var camera = get_viewport().get_camera()
			var pixelRayOrigin = camera.project_ray_origin(event.position)
			var pixelRayDir = camera.project_ray_normal(event.position)
			var pixelResult = get_world().direct_space_state.intersect_ray(pixelRayOrigin, pixelRayOrigin + pixelRayDir * 200.0, [], 2147483647, false, true)
			#if pixelResult:
			#	print("Hit at point: ", pixelResult.position, pixelResult.collider)
			if pixelResult:	
				var rayTarget = pixelResult.position
				var rayDir = (rayTarget - rayOrigin)
				rayDir = Vector3(rayDir.x, 0.0, rayDir.z);
				var rayEnd = rayOrigin + rayDir*20.0
				var result = get_world().direct_space_state.intersect_ray(rayOrigin, rayEnd, [self])
				if result:
					get_node("/root/World/RayDraw").queue_ray(rayOrigin, result.position)
					if result.collider is Enemy:
						#print("Enemy hit!")
						result.collider.take_damage(damage)
				else:
					# Miss
					get_node("/root/World/RayDraw").queue_ray(rayOrigin, rayEnd)
					#print("Hit at point: ", result.position, result.collider,  result.collider is Enemy, result.collider.get_script(), result.collider.get_script() is Enemy, result.collider_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#translate(get_input_direction() * delta * speed)
	if(linear_velocity.length() < maxSpeed):
		add_force(get_input_direction() * delta * accel, Vector3(0,0,0))
	pass

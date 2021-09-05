extends PlayerState
# Parent state for all movement-related states for the Player.
# Holds all of the base movement logic.
# Child states can override this state's functions or change its properties.
# This keeps the logic grouped in one location.

const rot_speed = 10.0
const gun_distance = 0.4
const running_gun_offset = 0.2

export var max_speed: = 6.0
export var move_speed: = 5.0
export var gravity = -80.0
export var jump_impulse = 25

var velocity: = Vector3.ZERO

var ray_target = null

#func unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("jump"):
#		_state_machine.transition_to("Move/Air", { velocity = velocity, jump_impulse = jump_impulse })


func _input(event):
	if event is InputEventMouse:
		var camera = get_viewport().get_camera()
		var pixelRayOrigin = camera.project_ray_origin(event.position)
		var pixelRayDir = camera.project_ray_normal(event.position)
		var pixelResult = player.get_world().direct_space_state.intersect_ray(pixelRayOrigin, pixelRayOrigin + pixelRayDir * 200.0, [], 2147483647, false, true)
		if pixelResult:	
			# look at target
			ray_target = pixelResult.position
			#gun.look_at(gun.global_transform.origin + rayDir, Vector3.UP)
			#gun.look_at(gun.global_transform.origin + rayDir, rayDir.cross(Vector3.UP))

func physics_process(delta: float) -> void:
	var input_direction: = get_input_direction()

	# Calculate a move direction vector relative to the camera
	# The basis stores the (right, up, -forwards) vectors of our camera.
	#var forwards: Vector3 = Vector3(1.0, 0.0, 0.0) * input_direction.z#player.camera.global_transform.basis.z * input_direction.z
	#var right: Vector3 = Vector3(0.0, 0.0, 1.0) * input_direction.x#player.camera.global_transform.basis.x * input_direction.x
	#var move_direction: = forwards + right
	var move_direction = input_direction
	if move_direction.length() > 1.0:
		move_direction = move_direction.normalized()
	move_direction.y = 0
	skin.move_direction = move_direction

	# Rotation
	#if move_direction:
	#	player.look_at(player.global_transform.origin + move_direction, Vector3.UP)
	if ray_target != null:
		var rayOrigin = player.global_transform.origin + Vector3(0.0, 0.0, 0.0)
		var rayDir = (ray_target - rayOrigin)
		rayDir = Vector3(rayDir.x, 0.0, rayDir.z).normalized()
		var gunDistance = gun_distance
		if _state_machine._state_name == "Run":
			gunDistance += running_gun_offset
		var gunPos = rayOrigin + rayDir * gunDistance
		var look_pos = player.global_transform.origin + rayDir
		var look_dir = rayDir
		var targetTransform = player.global_transform.looking_at(look_pos, Vector3.UP)
		player.global_transform = player.global_transform.interpolate_with(targetTransform, rot_speed*delta)
		target.global_transform.origin = gunPos
		gun.look_at(gun.global_transform.origin + Vector3.UP.cross(look_dir), look_dir)


	# Movement
	velocity = calculate_velocity(velocity, move_direction, delta)
	velocity = player.move_and_slide(velocity, Vector3.UP)


func enter(msg: Dictionary = {}) -> void:
	#player.camera.connect("aim_fired", self, "_on_Camera_aim_fired")
	pass


func exit() -> void:
	#player.camera.disconnect("aim_fired", self, "_on_Camera_aim_fired")
	pass


# Callback to transition to the optional Zip state
# It only works if the Zip state node exists.
# It is intended to work via signals
func _on_Camera_aim_fired(target_vector: Vector3) -> void:
	_state_machine.transition_to("Move/Zip", { target = target_vector })


static func get_input_direction() -> Vector3:
	return Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0,
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		)


func calculate_velocity(
		velocity_current: Vector3,
		move_direction: Vector3,
		delta: float
	) -> Vector3:
		var velocity_new: = velocity_current

		velocity_new = move_direction * move_speed
		if velocity_new.length() > max_speed:
			velocity_new = velocity_new.normalized() * max_speed
		velocity_new.y = velocity_current.y + gravity * delta

		return velocity_new

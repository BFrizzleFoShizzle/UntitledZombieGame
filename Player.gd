extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const accel = 2000.0
const maxSpeed = 3.0
var damage = 25.0
const attackKnockback = 200.0
const shellEjectForceMin = 250.0
const shellEjectForceMax = 350.0

const Enemy = preload("res://Enemy.gd")
const Casing = preload("res://Casing.tscn")
const GunSound = preload("res://PlayerGunSound.tscn")
onready var playerGun = get_node("PlayerGun")

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
	
func play_gunshot():
	var gunSound = GunSound.instance()
	add_child(gunSound)

func _input(event):
	if event is InputEventMouse:
		# update gun position
		# TODO refactor
		var rayOrigin = global_transform.origin + Vector3(0.0, 0.2, 0.0)
		
		var camera = get_viewport().get_camera()
		var pixelRayOrigin = camera.project_ray_origin(event.position)
		var pixelRayDir = camera.project_ray_normal(event.position)
		var pixelResult = get_world().direct_space_state.intersect_ray(pixelRayOrigin, pixelRayOrigin + pixelRayDir * 200.0, [], 2147483647, false, true)
		if pixelResult:	
			# look at target
			var rayTarget = pixelResult.position
			var rayDir = (rayTarget - rayOrigin).normalized()
			rayDir = Vector3(rayDir.x, 0.0, rayDir.z)
			var gunPos = rayOrigin + rayDir
			playerGun.global_transform.origin = gunPos
			playerGun.look_at(gunPos + rayDir, Vector3(0.0, 1.0, 0.0))
			
			if event is InputEventMouseButton && event.button_index  == 1 && event.pressed == true:
				# gunshot
				play_gunshot()
				
				# Create casing
				var casing = Casing.instance()
				get_node("/root/World").add_child(casing)
				casing.global_transform.origin = gunPos
				var casingMoveDir = rayDir.cross(Vector3(0.0,1.0,0.0))
				casingMoveDir += Vector3(0.0,1.0,0.0) * rand_range(-0.1, 0.1)
				casingMoveDir += rayDir * rand_range(-0.1, 0.1)
				casingMoveDir = casingMoveDir.normalized()
				var forceOrigin = Vector3(rand_range(-0.1,0.1), rand_range(-0.1,0.1), rand_range(-0.1,0.1))
				casing.add_force(rand_range(shellEjectForceMin, shellEjectForceMax) * casingMoveDir, forceOrigin)
				
				var rayEnd = rayOrigin + rayDir*20.0
				var result = get_world().direct_space_state.intersect_ray(gunPos, rayEnd, [self])
				if result:
					get_node("/root/World/RayDraw3D").queue_ray(gunPos, result.position)
					if result.collider is Enemy:
						#print("Enemy hit!")
						result.collider.take_damage(damage)
						# knockback
						#result.collider.add_force(Vector3(1.0, 0.0, 0.0) * attackKnockback, Vector3(0.0, 0.0, 0.0))
						result.collider.add_force(rayDir.normalized() * attackKnockback, Vector3(0.0, 0.0, 0.0))
				else:
					# Miss
					get_node("/root/World/RayDraw").queue_ray(gunPos, rayEnd)
					#print("Hit at point: ", result.position, result.collider,  result.collider is Enemy, result.collider.get_script(), result.collider.get_script() is Enemy, result.collider_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#translate(get_input_direction() * delta * speed)
	if(linear_velocity.length() < maxSpeed):
		add_force(get_input_direction() * delta * accel, Vector3(0,0,0))
	pass

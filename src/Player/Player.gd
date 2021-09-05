class_name Player
extends KinematicBody
# Helper class for the Player scene's scripts to be able to have access to the
# camera and its orientation.

#onready var camera: CameraRig = $CameraRig
onready var skin: Mannequiny = $Mannequiny
onready var state_machine: StateMachine = $StateMachine
onready var target:Spatial = $Target
onready var gun:Spatial = $Target/Hand

# HACK putting this on GunState causes it to be initialized for each instance
var _gun_stats = [
	# Pistol
	GunState.GunStats.new(
		preload("res://Gun1.tscn"),
		"Pistol", # name
		preload("res://PlayerGunSound.tscn"), # gun sound
		25.0, # damage
		200.0, # knockback
		1.0, # reloadTime
		12, # magazineCount
		0.02 # spread
	),
	# Sawn-off
	GunState.GunStats.new(
		preload("res://Gun3.tscn"),
		"Sawn-off", # name
		preload("res://PlayerGunSound2.tscn"), # gun sound
		10.0, # damage
		50.0, # knockback
		1.0, # reloadTime
		2, # magazineCount
		0.07, # spread
		10 # shots
	),
	# Uzi
	GunState.GunStats.new(
		preload("res://Gun2.tscn"),
		"Uzi", # name
		preload("res://PlayerGunSound.tscn"), # gun sound
		15.0, # damage
		150.0, # knockback
		1.0, # reloadTime
		30, # magazineCount
		0.05, # spread
		1, # shots
		true, # automatic
		1.0 / 20 # fire interval
	)
]

# Init gun
var _gun:int = GunState.Gun.PISTOL
var _gunState:GunState = GunState.new(_gun_stats[_gun])

const Enemy = preload("res://Enemy.gd")
const Casing = preload("res://Casing.tscn")
onready var rayDrawer = get_node("../RayDraw3D")
var casingSpawn: Spatial
var bulletSpawn: Spatial
var muzzleFlashLight: Light

const shellEjectForceMin = 150.0
const shellEjectForceMax = 250.0

# used for automatic weapons
var shooting = false


const rot_speed = 10.0
const gun_distance = 0.4
const running_gun_offset = 0.2
var ray_target = null

func _updateGunRefs():
	muzzleFlashLight = $Target/Hand/Gun/Flash
	casingSpawn = $Target/Hand/Gun/CasingSpawn
	bulletSpawn = $Target/Hand/Gun/BulletSpawn

func _input(event):
	if event is InputEventMouse:
		var camera = get_viewport().get_camera()
		var pixelRayOrigin = camera.project_ray_origin(event.position)
		var pixelRayDir = camera.project_ray_normal(event.position)
		var pixelResult = get_world().direct_space_state.intersect_ray(pixelRayOrigin, pixelRayOrigin + pixelRayDir * 200.0, [], 2147483647, false, true)
		if pixelResult:	
			# look at target
			ray_target = pixelResult.position
			
			if event is InputEventMouseButton && event.button_index  == 1 && event.pressed == true:
				shooting = true
			
			if event is InputEventMouseButton && event.button_index  == 1 && event.pressed == false:
				shooting = false

func _process(delta):
	_gunState.process(delta)
	
	# Rotation
	#if move_direction:
	#	player.look_at(player.global_transform.origin + move_direction, Vector3.UP)
	if ray_target != null:
		var rayOrigin = global_transform.origin + Vector3(0.0, 0.0, 0.0)
		var rayDir = (ray_target - rayOrigin)
		rayDir = Vector3(rayDir.x, 0.0, rayDir.z).normalized()
		var gunDistance = gun_distance
		if $StateMachine.state.name == "Run":
			gunDistance += running_gun_offset
		var gunPos = rayOrigin + rayDir * gunDistance
		var look_pos = global_transform.origin + rayDir
		var look_dir = rayDir
		var targetTransform = global_transform.looking_at(look_pos, Vector3.UP)
		global_transform = global_transform.interpolate_with(targetTransform, rot_speed*delta)
		target.global_transform.origin = gunPos
		gun.look_at(gun.global_transform.origin + Vector3.UP.cross(look_dir), look_dir)
		
	if shooting && _gunState.canShoot():
		_gunState.shoot()
		
		if(!_gunState.gunStats.automatic):
			shooting = false
		
		# gunshot
		play_gunshot()
		muzzleFlashLight.flash()
		
		var shotOrigin = bulletSpawn.global_transform.origin
		# before spread
		var aimDir = (ray_target - shotOrigin)
		aimDir = Vector3(aimDir.x, 0.0, aimDir.z).normalized()
		var aimOrthog = aimDir.cross(Vector3.UP)
		
		# Create casing
		var casing = Casing.instance()
		get_node("/root/World/GameWorld").add_child(casing)
		casing.global_transform = casingSpawn.global_transform
		var casingMoveDir = (aimOrthog + Vector3(0.0,0.2,0.0))
		casingMoveDir += Vector3.UP * rand_range(-0.1, 0.1)
		casingMoveDir += aimDir * rand_range(-0.1, 0.1)
		casingMoveDir = casingMoveDir.normalized()
		var forceOrigin = Vector3(rand_range(-0.1,0.1), rand_range(-0.1,0.1), rand_range(-0.1,0.1))
		casing.add_force(rand_range(shellEjectForceMin, shellEjectForceMax) * casingMoveDir, forceOrigin)
		
		for i in range(_gunState.gunStats.shots):
			# apply spread
			var shotDir = aimDir
			shotDir += aimOrthog * rand_range(-1.0, 1.0) * _gunState.gunStats.spread
			shotDir += Vector3.UP * rand_range(-1.0, 1.0) * _gunState.gunStats.spread
			shotDir = shotDir.normalized()
			
			var shotEnd = shotOrigin + shotDir*20.0
			var result = get_world().direct_space_state.intersect_ray(shotOrigin, shotEnd, [self])
			if result:
				rayDrawer.queue_ray(shotOrigin, result.position)
				if result.collider is Enemy:
					#print("Enemy hit!")
					result.collider.take_damage(getDamage())
					# knockback
					#result.collider.add_force(Vector3(1.0, 0.0, 0.0) * attackKnockback, Vector3(0.0, 0.0, 0.0))
					result.collider.add_force(shotDir.normalized() * getKnockback(), Vector3(0.0, 0.0, 0.0))
			else:
				# Miss
				rayDrawer.queue_ray(shotOrigin, shotEnd)

func _ready():
	#change_gun(GunState.Gun.SAWN_OFF)
	_updateGunRefs()
	
func change_gun(gun:int):
	if _gun == gun:
		return
	
	_gun = gun
	_gunState = GunState.new(_gun_stats[_gun])
	$Target/Hand/Gun.free()
	var newGun = _gunState.gunStats.factory.instance()
	$Target/Hand.add_child(newGun, true)
	
	# Update gun part refferences
	_updateGunRefs()

func play_gunshot():
	var gunSound = _gunState.gunStats.fireSound.instance()
	add_child(gunSound)

func getDamage():
	return _gunState.gunStats.damage
	
func getKnockback():
	return _gunState.gunStats.attackKnockback


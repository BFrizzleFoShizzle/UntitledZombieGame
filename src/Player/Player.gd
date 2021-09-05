class_name Player
extends KinematicBody
# Helper class for the Player scene's scripts to be able to have access to the
# camera and its orientation.

#onready var camera: CameraRig = $CameraRig
onready var skin: Mannequiny = $Mannequiny
onready var state_machine: StateMachine = $StateMachine
onready var target:Spatial = $Target
onready var gun:Spatial = $Target/Hand

enum Gun {
	PISTOL
	UZI
}

# HACK putting this on GunState causes it to be initialized for each instance
var _gun_stats = [
	# Pistol
	GunState.GunStats.new(
		preload("res://Gun1.tscn"),
		25.0, # damage
		200.0, # knockback
		1.0, #reloadTime
		12 #magazineCount
	),
	# Uzi
	GunState.GunStats.new(
		preload("res://Gun2.tscn"),
		15.0, # damage
		150.0, # knockback
		1.0, #reloadTime
		30, #magazineCount
		1, # shots
		true, # automatic
		1.0 / 20 # fire interval
	)
]

# Init gun
var _gun:int = Gun.PISTOL
var _gunState:GunState = GunState.new(_gun_stats[_gun])

const Enemy = preload("res://Enemy.gd")
const Casing = preload("res://Casing.tscn")
const GunSound = preload("res://PlayerGunSound.tscn")
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
				if canAttack():
					shooting = true
			
			if event is InputEventMouseButton && event.button_index  == 1 && event.pressed == false:
				shooting = false
	
	if shooting && canAttack():
		shoot()
		
		if(!isAutomatic()):
			shooting = false
		
		# gunshot
		play_gunshot()
		muzzleFlashLight.flash()
		
		var shotOrigin = bulletSpawn.global_transform.origin
		var shotDir = (ray_target - shotOrigin)
		shotDir = Vector3(shotDir.x, 0.0, shotDir.z).normalized()
		
		# Create casing
		var casing = Casing.instance()
		get_node("/root/World/GameWorld").add_child(casing)
		casing.global_transform = casingSpawn.global_transform
		var casingMoveDir = (shotDir.cross(Vector3(0.0,1.0,0.0)) + Vector3(0.0,0.2,0.0))
		casingMoveDir += Vector3(0.0,1.0,0.0) * rand_range(-0.1, 0.1)
		casingMoveDir += shotDir * rand_range(-0.1, 0.1)
		casingMoveDir = casingMoveDir.normalized()
		var forceOrigin = Vector3(rand_range(-0.1,0.1), rand_range(-0.1,0.1), rand_range(-0.1,0.1))
		casing.add_force(rand_range(shellEjectForceMin, shellEjectForceMax) * casingMoveDir, forceOrigin)
		
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
	var gunSound = GunSound.instance()
	add_child(gunSound)

func _ready():
	change_gun(Gun.UZI)
	_updateGunRefs()

func getDamage():
	return _gunState.gunStats.damage
	
func getKnockback():
	return _gunState.gunStats.attackKnockback

func canAttack():
	return _gunState.canShoot()

func isAutomatic():
	return _gunState.gunStats.automatic

func shoot():
	_gunState.shoot()
#
#func _get_configuration_warning() -> String:
#	return "Missing camera node" if not camera else ""

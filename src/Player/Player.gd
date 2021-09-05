tool
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

class GunStats:
	var factory
	var damage: float
	var attackKnockback: float
	var fireInterval: float
	var reloadTime: float
	var automatic: bool
	var shots: int
	var magazineCount: int
	func _init(factory, damage: float, attackKnockback: float, reloadTime: float, 
			magazineCount: int, shots: int = 1, automatic: bool = false, fireInterval: float = 0.01):
		self.factory = factory
		self.damage = damage
		self.attackKnockback = attackKnockback
		self.fireInterval = fireInterval
		self.reloadTime = reloadTime
		self.automatic = automatic
		self.shots = shots
		self.magazineCount = magazineCount

class GunState:
	var gunStats: GunStats
	var bulletsInMag: int
	var currShotInterval: float
	var currReloadTime: float
	func _init(gunStats:GunStats):
		self.gunStats = gunStats
		bulletsInMag = gunStats.magazineCount
		currShotInterval = 0.0
		currReloadTime = 0.0
	
	func canShoot():
		return currShotInterval <= 0.0 && bulletsInMag > 0
		
	func shoot():
		if !canShoot():
			# TODO click noise
			return
		
		# TODO move more shot stuff here?
		bulletsInMag -= 1
		if bulletsInMag > 0:
			currShotInterval = gunStats.fireInterval
		else:
			currReloadTime = gunStats.reloadTime
	
	func process(delta:float):
		currShotInterval -= delta
		currReloadTime -= delta
		if bulletsInMag <= 0 && currReloadTime <= 0.0:
			bulletsInMag = gunStats.magazineCount

var gun_stats = [
	# Pistol
	GunStats.new(
		preload("res://Gun1.tscn"),
		25.0, # damage
		200.0, # knockback
		1.0, #reloadTime
		12 #magazineCount
	),
	# Uzi
	GunStats.new(
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
var _gunState:GunState = GunState.new(gun_stats[_gun])

const Enemy = preload("res://Enemy.gd")
const Casing = preload("res://Casing.tscn")
const GunSound = preload("res://PlayerGunSound.tscn")
onready var rayDrawer = get_node("../RayDraw3D")
var casingSpawn: Spatial
var bulletSpawn: Spatial
var muzzleFlashLight: Light

const shellEjectForceMin = 150.0
const shellEjectForceMax = 250.0

func _updateGunRefs():
	muzzleFlashLight = $Target/Hand/Gun/Flash
	casingSpawn = $Target/Hand/Gun/CasingSpawn
	bulletSpawn = $Target/Hand/Gun/BulletSpawn

func _process(delta):
	_gunState.process(delta)

func change_gun(gun:int):
	if _gun == gun:
		return
	
	_gun = gun
	_gunState = GunState.new(gun_stats[_gun])
	$Target/Hand/Gun.free()
	var newGun = gun_stats[_gun].factory.instance()
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

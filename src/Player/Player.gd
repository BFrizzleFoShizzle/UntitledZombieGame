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

const Enemy = preload("res://Enemy.gd")
const Casing = preload("res://Casing.tscn")
const GunSound = preload("res://PlayerGunSound.tscn")
onready var muzzleFlashLight = $Target/Hand/Gun/Flash
onready var rayDrawer = get_node("../RayDraw3D")
onready var casingSpawn = $Target/Hand/Gun/CasingSpawn
onready var bulletSpawn = $Target/Hand/Gun/BulletSpawn

var damage = 25.0
const attackKnockback = 200.0
const shellEjectForceMin = 150.0
const shellEjectForceMax = 250.0

func play_gunshot():
	var gunSound = GunSound.instance()
	add_child(gunSound)

#
#func _get_configuration_warning() -> String:
#	return "Missing camera node" if not camera else ""

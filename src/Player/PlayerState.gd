extends State
class_name PlayerState
# Base type for the player's state classes. Contains boilerplate code to get
# autocompletion and type hints.


var player: Player
var skin: Mannequiny
var target: Spatial
var gun: Spatial


func _ready() -> void:
	yield(owner, "ready")
	player = owner
	skin = owner.skin
	target = owner.target
	gun = owner.gun

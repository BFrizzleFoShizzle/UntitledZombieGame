extends "res://Enemy.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	health = 200.0
	damage = 5
	maxSpeed = 5.0
	$Mannequiny.transition_to(Mannequiny.States.RUN)
	$Mannequiny/AnimationPlayer.playback_speed = 0.8
	pass # Replace with function body.

func attack():
	$Mannequiny/AnimationPlayer.playback_speed = 1.0
	.attack()
	

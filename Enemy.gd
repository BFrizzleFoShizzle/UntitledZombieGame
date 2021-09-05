extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var maxSpeed = 1.0
const accel = 2000.0
var health = 100.0

const attackTime = 1.0
const attackTimeRand = 0.1
# attack anim time
const attackCycleLength = 0.2
var currAttackTime = 0.0
const damage = 3.0


onready var wall = get_node("../Terrain/Wall/WallOmniCollider")
onready var world = get_node("/root/World")

# Called when the node enters the scene tree for the first time.
func _ready():
	contact_monitor = true
	contacts_reported = 5
	look_at(global_transform.origin + Vector3(1.0,0.0,0.0), Vector3.UP)
	$Mannequiny.set_is_moving(true)
	$Mannequiny.set_move_direction(Vector3(1.0,0.0,0.0))
	$Mannequiny.transition_to(Mannequiny.States.WALK)
	pass # Replace with function body.

# used to set max velocity
func _integrate_forces(state):
	if(state.linear_velocity.length() > maxSpeed):
		state.linear_velocity /= (state.linear_velocity.length() / maxSpeed)
	pass

func attack():
	world.damage_wall(damage)
	$Mannequiny.set_is_moving(false)
	$Mannequiny.set_move_direction(Vector3(0.0,0.0,0.0))
	$Mannequiny.transition_to(Mannequiny.States.ATTACK)
	currAttackTime = attackTime + rand_range(0.0,attackTimeRand)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currAttackTime -= delta
	if currAttackTime <= 0.0:
		if wall in get_colliding_bodies():
			attack()
	#move_and_collide(Vector3(-speed * delta, 0.0, 0.0 ))
	add_force(Vector3(-1.0, 0.0, 0.0) * delta * accel, Vector3(0,0,0))
	pass

func take_damage(damage):
	health = max(0.0, health-damage)
	if health == 0.0:
		queue_free()

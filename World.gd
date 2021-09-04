extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SpawnTime = 1.0
const SpawnOrigin = Vector3(10.0, 0.0, -2.5)
# multiply by 0..1 to get spawn pos
const SpawnRandomDir = Vector3(0.0, 0.0, 5.0)
var currSpawnTime = 0.0
var EnemyInst = load("res://Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currSpawnTime += delta
	if(currSpawnTime > SpawnTime):
		currSpawnTime -= SpawnTime
		var newEnemy = EnemyInst.instance()
		newEnemy.translation = SpawnOrigin + SpawnRandomDir * rand_range(0.0, 1.0)
		add_child(newEnemy)
	pass
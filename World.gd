extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const MinSpawnTime = 1.0
const MaxSpawnTime = 1.5
const SpawnOrigin = Vector3(10.0, 0.0, -2.5)
# multiply by 0..1 to get spawn pos
const SpawnRandomDir = Vector3(0.0, 0.0, 5.0)
var nextSpawnTime = 0.0
var currSpawnTime = 0.0
var EnemyInst = load("res://Enemy.tscn")
var EnemyFastInst = load("res://EnemyFast.tscn")

var wallHealth = 100.0

enum EnemyType {
	NORMAL
	FAST
	COUNT
}

onready var healthText = find_node("HealthText")
onready var gameWorld = get_node("GameWorld")

func damage_wall(damage):
	wallHealth -= damage
	wallHealth = max(wallHealth, 0.0)
	$GameUI/HBoxContainer/HealthText.text = str(wallHealth)
	if wallHealth == 0.0:
		gameWorld.get_tree().paused = true
		$GameOverUI.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currSpawnTime += delta
	if(currSpawnTime > nextSpawnTime):
		currSpawnTime -= nextSpawnTime
		nextSpawnTime = rand_range(MinSpawnTime, MaxSpawnTime)
		var randType = min(int(rand_range(0.0, EnemyType.COUNT)), EnemyType.COUNT - 1)
		var newEnemy = null
		if randType == EnemyType.NORMAL:
			newEnemy = EnemyInst.instance()
		elif randType == EnemyType.FAST:
			newEnemy = EnemyFastInst.instance()
		newEnemy.translation = SpawnOrigin + SpawnRandomDir * rand_range(0.0, 1.0)
		gameWorld.add_child(newEnemy)
	pass

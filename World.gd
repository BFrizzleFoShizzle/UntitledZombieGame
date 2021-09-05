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

const maxWallHealth = 100.0
var wallHealth = maxWallHealth

# number of living enemies
var enemyCount = 0
var totalKills = 0

const levelTimeLength = 60.0
var levelTimer = levelTimeLength

enum EnemyType {
	NORMAL
	FAST
	COUNT
}

onready var healthText = find_node("HealthText")
onready var gameWorld = get_node("GameWorld")

# inter-level stuff
var playerProgress:PlayerProgression = PlayerProgression.new()
var score = 0
export (NodePath) var freeHoursLabelPath
export (NodePath) var repairHoursLabelPath
export (NodePath) var searchHoursLabelPath
export (NodePath) var relaxHoursLabelPath
export (NodePath) var dayLabelPath
export (NodePath) var killsLabelPath
export (NodePath) var scoreLabelPath
export (NodePath) var newWallHealthLabelPath

onready var freeHoursLabel:Label = get_node(freeHoursLabelPath)
onready var repairHoursLabel:Label = get_node(repairHoursLabelPath)
onready var searchHoursLabel:Label = get_node(searchHoursLabelPath)
onready var relaxHoursLabel:Label = get_node(relaxHoursLabelPath)
onready var dayLabel:Label = get_node(dayLabelPath)
onready var killsLabel:Label = get_node(killsLabelPath)
onready var scoreLabel:Label = get_node(scoreLabelPath)
onready var newWallHealthLabel:Label = get_node(newWallHealthLabelPath)

func updateLevelEndUI():
	freeHoursLabel.text = str(playerProgress.getFreeHours())
	repairHoursLabel.text = str(playerProgress.getAllocatedHours(PlayerProgression.Type.REPAIR))
	searchHoursLabel.text = str(playerProgress.getAllocatedHours(PlayerProgression.Type.SEARCH))
	relaxHoursLabel.text = str(playerProgress.getAllocatedHours(PlayerProgression.Type.RELAX))
	var relaxScore = playerProgress.getRelaxScore()
	dayLabel.text = str(playerProgress.day)
	killsLabel.text = str(totalKills)
	scoreLabel.text = str(score + relaxScore)
	newWallHealthLabel.text = str(min(maxWallHealth, wallHealth + playerProgress.getAmountRepaired()))
	
func startNextLevel():
	# repair
	var healAmount = playerProgress.getAmountRepaired()
	wallHealth += healAmount
	wallHealth = min(maxWallHealth, wallHealth)
	$GameUI/HBoxContainer/HealthText.text = str(wallHealth)
	
	if playerProgress.unlockNextGun():
		$GameWorld/Player.change_gun(Player.Gun.UZI)
	
	# TODO search + rest
	playerProgress.endDay()
	totalKills = 0
	levelTimer = levelTimeLength
	$LevelEndUI.visible = false
	gameWorld.get_tree().paused = false

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
	updateLevelEndUI()
	pass # Replace with function body.

func addEnemyDeath():
	enemyCount -= 1
	totalKills += 1

func _endLevel():
	gameWorld.get_tree().paused = true
	score += totalKills * 10.0
	updateLevelEndUI()
	$LevelEndUI.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	levelTimer -= delta
	if levelTimer > 0.0:
		currSpawnTime += delta
	elif enemyCount == 0:
		# end level
		_endLevel()
	if(currSpawnTime > nextSpawnTime):
		enemyCount += 1
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

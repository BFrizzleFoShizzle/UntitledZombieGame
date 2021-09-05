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
var EnemyStrongInst = load("res://EnemyStrong.tscn")
var EnemyFastStrongInst = load("res://EnemyFastStrong.tscn")

const maxWallHealth = 100.0
var wallHealth = maxWallHealth

# number of living enemies
var enemyCount = 0
var totalKills = 0

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
export (NodePath) var weaponSelectMessageLabelPath
export (NodePath) var weapon1ButtonPath
export (NodePath) var weapon2ButtonPath
export (NodePath) var weapon3ButtonPath
export (NodePath) var weapon4ButtonPath

onready var freeHoursLabel:Label = get_node(freeHoursLabelPath)
onready var repairHoursLabel:Label = get_node(repairHoursLabelPath)
onready var searchHoursLabel:Label = get_node(searchHoursLabelPath)
onready var relaxHoursLabel:Label = get_node(relaxHoursLabelPath)
onready var dayLabel:Label = get_node(dayLabelPath)
onready var killsLabel:Label = get_node(killsLabelPath)
onready var scoreLabel:Label = get_node(scoreLabelPath)
onready var newWallHealthLabel:Label = get_node(newWallHealthLabelPath)
onready var weaponSelectMessageLabel:Label = get_node(weaponSelectMessageLabelPath)
onready var weaponSelectButtons = [
	get_node(weapon1ButtonPath),
	get_node(weapon2ButtonPath),
	get_node(weapon3ButtonPath),
	get_node(weapon4ButtonPath),
]

var levelTimer = playerProgress.getRoundTime()

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

func openWeaponSelect():
	# repair
	var healAmount = playerProgress.getAmountRepaired()
	wallHealth += healAmount
	wallHealth = min(maxWallHealth, wallHealth)
	$GameUI/HBoxContainer/HealthText.text = str(wallHealth)
	
	weaponSelectMessageLabel.text = "Select your weapon."
	if playerProgress.unlockNextGun():
		var newGunIdx = playerProgress.getNextGunUnlock()
		var gunName = $GameWorld/Player._gun_stats[newGunIdx].name
		weaponSelectMessageLabel.text = "New weapon unlocked: " + $GameWorld/Player._gun_stats[newGunIdx].name
		weaponSelectButtons[newGunIdx].text = gunName
		weaponSelectButtons[newGunIdx].disabled = false
		
	$LevelEndUI.visible = false
	$WeaponSelectUI.visible = true
	
	playerProgress.endDay()
	totalKills = 0
	

func startNextLevel():
	levelTimer = playerProgress.getRoundTime()
	$WeaponSelectUI.visible = false
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

func pause():
	gameWorld.get_tree().paused = true
	
func unpause():
	var allPanelsInvisible = true
	allPanelsInvisible = allPanelsInvisible && !$GameOverUI.visible
	allPanelsInvisible = allPanelsInvisible && !$LevelEndUI.visible
	allPanelsInvisible = allPanelsInvisible && !$WeaponSelectUI.visible
	allPanelsInvisible = allPanelsInvisible && !$PauseMenu.visible
	if allPanelsInvisible:
		gameWorld.get_tree().paused = false

func _endLevel():
	gameWorld.get_tree().paused = true
	score += totalKills * 10.0
	updateLevelEndUI()
	$LevelEndUI.visible = true
	unpause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# pause menu
	if Input.is_action_pressed("pause_menu"):
		$PauseMenu.visible = true
		pause()
	
	# don't process while paused	
	if gameWorld.get_tree().paused == true:
		return
	
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
		var enemyType = playerProgress.getNextEnemyType()
		var newEnemy = null
		if enemyType == PlayerProgression.EnemyType.NORMAL:
			newEnemy = EnemyInst.instance()
		elif enemyType == PlayerProgression.EnemyType.FAST:
			newEnemy = EnemyFastInst.instance()
		elif enemyType == PlayerProgression.EnemyType.STRONG:
			newEnemy = EnemyStrongInst.instance()
		elif enemyType == PlayerProgression.EnemyType.FAST_STRONG:
			newEnemy = EnemyFastStrongInst.instance()
		newEnemy.translation = SpawnOrigin + SpawnRandomDir * rand_range(0.0, 1.0)
		gameWorld.add_child(newEnemy)
	pass
	
func setPlayerWeapon(weaponIdx:int):
	$GameWorld/Player.change_gun(weaponIdx)

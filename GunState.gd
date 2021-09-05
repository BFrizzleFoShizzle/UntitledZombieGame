class_name GunState

enum Gun {
	PISTOL
	SAWN_OFF
	UZI
}

class GunStats:
	var factory
	var name: String
	var fireSound
	var damage: float
	var attackKnockback: float
	var fireInterval: float
	var reloadTime: float
	var automatic: bool
	var shots: int
	var magazineCount: int
	var spread: float
	func _init(factory, name:String, fireSound, damage: float, attackKnockback: float, reloadTime: float, 
			magazineCount: int, spread: float, shots: int = 1, automatic: bool = false, fireInterval: float = 0.01):
		self.factory = factory
		self.name = name
		self.fireSound = fireSound
		self.damage = damage
		self.attackKnockback = attackKnockback
		self.fireInterval = fireInterval
		self.reloadTime = reloadTime
		self.automatic = automatic
		self.shots = shots
		self.magazineCount = magazineCount
		self.spread = spread

# instance stuff
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

func isReloading():
	return bulletsInMag == 0

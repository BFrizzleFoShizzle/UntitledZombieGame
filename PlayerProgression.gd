class_name PlayerProgression

enum Type {
	REPAIR
	SEARCH
	RELAX
}

enum Direction {
	POSITIVE
	NEGATIVE
}

var day = 1

const hoursPerDay = 12
var hoursFree = hoursPerDay
var hoursRepair = 0
var hoursSearch = 0
var hoursRelax = 0

# 1.5 days for first, +1 day for each unlock
var hoursToNextWeapon = 18
var currHoursSearched = 0

# difficulty scaling stuff
const roundLengthMax = 90.0
var roundLength = 30.0
# probability of zombie spawn being upgraded
# normal zombie -> fast zombie -> strong zombie -> fast strong zombie
const pFastMax = 0.9
const pStrongMax = 0.9
const pFastStrongMax = 0.9
var pFast = 0.1
# don't start till second round
var pStrong  = 0.0
# don't start till 3rd round
var pFastStrong = -0.1

enum EnemyType {
	NORMAL
	FAST
	STRONG
	FAST_STRONG
	COUNT
}

var unlockedGunIdx = GunState.Gun.PISTOL

# Would be nice if enums had static typing...
func getAllocatedHours(type:int):
	if type == Type.REPAIR:
		return hoursRepair
	elif type == Type.SEARCH:
		return hoursSearch
	elif type == Type.RELAX:
		return hoursRelax
	else:
		return -1

func _setAllocatedHours(type:int, value:int):
	if type == Type.REPAIR:
		hoursRepair = value
	elif type == Type.SEARCH:
		hoursSearch = value
	elif type == Type.RELAX:
		hoursRelax = value

func getFreeHours():
	return hoursFree

func allocateHour(type:int, direction:int):
	var currVal = getAllocatedHours(type)
	if direction == Direction.NEGATIVE && currVal > 0:
		currVal -= 1
		hoursFree += 1
	elif direction == Direction.POSITIVE && hoursFree > 0:
		currVal += 1
		hoursFree -= 1
	_setAllocatedHours(type, currVal)

func getAmountRepaired():
	return hoursRepair * 5.0

func getRelaxScore():
	return hoursRelax * 50.0

func unlockNextGun():
	return currHoursSearched + hoursSearch > hoursToNextWeapon

func endDay():
	day += 1
	
	currHoursSearched += hoursSearch
	
	# difficulty increase
	pFast = min(pFast + 0.1, pFastMax)
	pStrong = min(pStrong + 0.1, pStrongMax)
	pFastStrong = min(pFastStrong + 0.1, pFastStrongMax)
	roundLength = min(roundLength + 5, roundLengthMax)
	
	# reset
	hoursFree = hoursPerDay
	hoursRepair = 0
	hoursSearch = 0
	hoursRelax = 0
	
	if unlockNextGun():
		currHoursSearched -= hoursToNextWeapon
		hoursToNextWeapon += 12
		unlockedGunIdx += 1
	
# this is where difficulty scaling happens
func getNextEnemyType():
	# return on failed check
	if(rand_range(0.0, 1.0) > pFast):
		return EnemyType.NORMAL
	if(rand_range(0.0, 1.0) > pStrong):
		return EnemyType.FAST
	if(rand_range(0.0, 1.0) > pFastStrong):
		return EnemyType.STRONG
	# All checks succeed, max. difficulty
	return EnemyType.FAST_STRONG

func getRoundTime():
	return roundLength
	
func getNextGunUnlock():
	return unlockedGunIdx + 1

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

func endDay():
	day += 1
	
	# TODO handle searching
	
	# reset
	hoursFree = hoursPerDay
	hoursRepair = 0
	hoursSearch = 0
	hoursRelax = 0

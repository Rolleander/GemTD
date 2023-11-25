
class_name DamageCounter

const WINDOW = 3

var current = 0
var current_time = 0
var total = 0
var dps = 0
var entries = []
var time = 0

func dealt(damage : float):	
	total += damage
	current += damage
	current_time = 0
	var entry = { "time" : time, "damage" : damage}
	entries.append(entry)
	
func reset():
	total = 0
	dps = 0

func update(delta : float):
	time += delta
	current_time += delta
	if current_time > 0.5:
		current  = 0
	dps = 0	
	for i in range(entries.size()-1, -1, -1):
		var entry = entries[i] 
		if  time >= entry.time + WINDOW  :
			entries.remove_at(i)
		else:
			dps += entry.damage
	var count = entries.size()
	if count > 0:		
		dps = roundf(dps / WINDOW) 		



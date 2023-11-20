extends ProjectileAttack

var roll_rounds = 0
var waves = 0
var desc_text

func _ready():
	super()
	roll_rounds = 5 - gem.quality
	if gem.quality == GemQualityInfo.Quality.GREAT:
		roll_rounds = 1
	if roll_rounds > 1:
		desc_text = "Generates 1 free Re-Roll every "+str(roll_rounds)+" waves"
	else:
		desc_text = "Generates 1 free Re-Roll every wave"
	_update_description()
	Events.wave_ended.connect(_wave_ended)
	
func _update_description():	
	description = desc_text
	if roll_rounds > 1:
		description += "\n("+str(roll_rounds-waves)+" Waves remaining)"

func _wave_ended():
	waves += 1
	if waves >= roll_rounds:
		waves = 0
		Game.free_rerolls+=1
	_update_description()

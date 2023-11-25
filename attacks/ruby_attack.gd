extends ProjectileAttack

func _ready():
	super()
	if gem.quality != GemQualityInfo.Quality.GREAT:
		return
	splash_range += 1
	parallel_targets = 3
	description += " and attacks "+str(parallel_targets)+" targets"

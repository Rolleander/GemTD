extends ProjectileAttack


func _ready():
	super()
	var speed_mul =  0.9 - gem.quality * 0.1
	if gem.quality == GemQualityInfo.Quality.GREAT:
		speed_mul = 0.5
	var slow_percent = (1 - speed_mul) * 100
	var slow_buff = hit_buffs[0]
	slow_buff.value = speed_mul
	slow_buff.name = "Saphire Slow "+str(gem.quality+1)
	slow_buff.description = str(speed_mul)+"% Slow"
	slow_buff.stack_group = "Saphire_"+str(gem.quality)
	slow_buff.priority = gem.quality
	

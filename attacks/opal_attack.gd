extends ProjectileAttack


func _ready():
	super()
	var speed_mul =  0.9 - gem.quality * 0.05
	if gem.quality == GemQualityInfo.Quality.PERFECT:
		speed_mul = 0.65
	if gem.quality == GemQualityInfo.Quality.GREAT:
		speed_mul = 0.5
	var buff_percent = (1 - speed_mul) * 100
	var atkdelay_buff = tower_buffs[0]
	atkdelay_buff.value = speed_mul
	atkdelay_buff.name = "Opal Haste "+str(gem.quality+1)
	atkdelay_buff.description = str(buff_percent)+"% Attack Speed Increase"
	atkdelay_buff.stack_group = "OpalHaste"
	atkdelay_buff.priority = gem.quality
	

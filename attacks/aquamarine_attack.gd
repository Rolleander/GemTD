extends ProjectileAttack


func _ready():
	super()
	if gem.quality != GemQualityInfo.Quality.GREAT:
		return
	var speed_mul =  0.85
	var buff_percent = (1 - speed_mul) * 100
	var buff = TowerBuff.new()
	buff.value = speed_mul
	buff.name = "Aquamarine Haste "
	buff.description = "+ "+str(buff_percent)+"% Attack Speed"
	buff.stack_group = "AquaHaste"
	buff.priority = gem.quality
	tower_buffs.append(buff)

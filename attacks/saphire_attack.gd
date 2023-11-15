extends ProjectileAttack


func _ready():
	super()
	attack_scale += gem.quality *.1
	var speed_mul =  0.8 - gem.quality * 0.05
	var slow_buff = hit_buffs[0]
	if gem.quality == GemQualityInfo.Quality.GREAT:
		speed_mul = 0.5
		slow_buff.duration = 10
		splash_range = 100
	var slow_percent = (1 - speed_mul) * 100
	slow_buff.value = speed_mul
	slow_buff.name = "Saphire Slow "+str(gem.quality+1)
	slow_buff.description = str(speed_mul)+"% Slow"
	slow_buff.stack_group = "SaphireSlow"
	slow_buff.priority = gem.quality
	
func _spawn_bullet(enemy : Enemy):
	var bullet = super(enemy)
	bullet.fadeout = 0.4
	return bullet

extends ProjectileAttack

func _ready():
	super()
	attack_scale += gem.quality *.1
	var speed_mul =  0.9 - gem.quality * 0.05
	var duration = 3 + gem.quality
	var slow_buff = hit_buffs[0]
	var poison_buff = hit_buffs[1]
	if gem.quality == GemQualityInfo.Quality.CHIPPED:
		poison_buff.value = -6
	if gem.quality == GemQualityInfo.Quality.FLAWED:
		poison_buff.value = -16
	if gem.quality == GemQualityInfo.Quality.NORMAL:
		poison_buff.value = -40
	if gem.quality == GemQualityInfo.Quality.FLAWLESS:
		poison_buff.value = -72
	if gem.quality == GemQualityInfo.Quality.PERFECT:
		poison_buff.value = -440
		duration = 8
	if gem.quality == GemQualityInfo.Quality.GREAT:
		poison_buff.value = -550
		speed_mul = 0.6
		duration = 10
		splash_range = 2.5
	slow_buff.duration =duration
	poison_buff.duration =duration
	var slow_percent = (1 - speed_mul) * 100
	slow_buff.value = speed_mul
	slow_buff.name = "Emerald Slow "+str(gem.quality+1)
	slow_buff.description = str((1-speed_mul)*100)+"% Slow"
	slow_buff.stack_group = "EmeraldSlow"
	slow_buff.priority = gem.quality
	poison_buff.name = "Emerald Poison "+str(gem.quality+1)
	poison_buff.stack_group = "EmeraldPoison"
	poison_buff.priority = gem.quality	
	poison_buff.description = str((poison_buff.value*-1) / poison_buff.duration) +" Damage per second"


func _spawn_bullet(enemy : Enemy):
	var bullet = super(enemy)
	bullet.fadeout = 0.7
	return bullet

extends ProjectileAttack

func _ready():
	super()
	if gem.quality != GemQualityInfo.Quality.GREAT:
		return
	var buff = EnemyBuff.new()
	buff.attribute = EnemyBuff.Attribute.ARMOR
	buff.operation = EnemyBuff.Operation.MUL
	buff.value = 0.85
	buff.description = "-15% Armor for air"
	buff.name = "Great Amethyst Armor Loss"
	buff.stack_group = "GreatAmethystArmorLoss"
	aura_buffs.append(buff)

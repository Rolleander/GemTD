extends ProjectileAttack
var CRIT_SCALE = 1.5
var CRIT_DMG = 2.0
var CRIT_CHANCE = 0.25

func _ready():
	super()
	if gem.quality == GemQualityInfo.Quality.GREAT:
		CRIT_SCALE = 2.0
		CRIT_DMG = 5.0
		description = "Only hits ground units, chance to crit for 5x damage"
		var buff = EnemyBuff.new()
		buff.attribute = EnemyBuff.Attribute.ARMOR
		buff.operation = EnemyBuff.Operation.MUL
		buff.value = 0.85
		buff.description = "-15% Armor"
		buff.name = "Great Diamond Armor Loss"
		buff.stack_group = "GreatDiamondArmorLoss"
		aura_buffs.append(buff)

func _spawn_bullet(enemy : Enemy):
	var bullet = super(enemy)
	if randf() <= CRIT_CHANCE:
		bullet.hit_damage_scale = CRIT_DMG
		var render = bullet.get_child(0)
		render.transform =  render.transform.scaled(Vector2(CRIT_SCALE, CRIT_SCALE))
		Events.overlay_text(gem, "CRIT!!!")
	return bullet

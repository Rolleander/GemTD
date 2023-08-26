extends ProjectileAttack
const CRIT_SCALE = 1.5
const CRIT_DMG = 4.0 
const CRIT_CHANCE = 0.2

func _spawn_bullet(enemy : Enemy):
	var bullet = super(enemy)
	if randf() <= CRIT_CHANCE:
		bullet.hit_damage_scale = CRIT_DMG
		var render = bullet.get_child(0)
		render.transform =  render.transform.scaled(Vector2(CRIT_SCALE, CRIT_SCALE))
		Events.overlay_text(gem, "CRIT!!!")
	return bullet

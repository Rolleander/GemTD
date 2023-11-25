extends Attack

class_name AuraAttack

const HIT_DELAY = 0.1
var passed = 0

func _physics_process(delta):
	if !active:
		return
	passed += delta	
	if passed < HIT_DELAY:
		return
	if aura_buffs.size() > 0:
		_apply_aura_buffs()	
	hit_damage_scale = (1 / attack_delay) * passed
	passed = 0
	for enemy in _targetable_enemies():
		_hit(enemy)

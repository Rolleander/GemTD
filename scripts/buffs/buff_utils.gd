extends Node

const LEVEL_DMG_INC = 0.1

func add_enemy_buff (enemy : Enemy, source : Gem,  buff : EnemyBuff) -> bool:	
	if !_apply_buff(enemy.buffs, buff):
		return false
	var instance =  EnemyBuffInstance.new()		
	instance.buff = buff	
	instance.source = source	
	instance.target = enemy
	if buff.attribute == EnemyBuff.Attribute.HEALTH:
		instance.target_value = enemy.health
	elif buff.attribute == EnemyBuff.Attribute.ARMOR:
		instance.target_value = enemy.armor
	elif buff.attribute == EnemyBuff.Attribute.SPEED:
		instance.target_value = enemy.speed
	enemy.buffs.append(instance)
	return true

func _apply_buff(buffs: Array, buff : Buff) -> bool:
	if buff.stack_group !=null:
		for b in buffs:
			if b.buff.stack_group == buff.stack_group:
				if b.buff.priority <= buff.priority:
					buffs.erase(b)
					if b.buff.permanent:
						b.target_value.apply_permanent(b)
					break
				else:
					return false
	return true
	
func _apply_tower_buff(buffs: Array, buff : TowerBuff) -> bool:
	if buff.stack_group !=null:
		for b in buffs:
			if b.stack_group == buff.stack_group:
				if b.priority <= buff.priority:
					buffs.erase(b)
					break
				else:
					return false
	buffs.append(buff)				
	return true

func progress_enemy_buffs(enemy : Enemy, delta):
	for i in range(enemy.buffs.size()-1, -1, -1):
		var buff = enemy.buffs[i] as EnemyBuffInstance
		if  buff.done:
			enemy.buffs.remove_at(i)
			continue
		buff.update(delta)

func update_tower_buffs():
	for gem in Game.get_gems():
		gem.buffs.clear()
		if gem.level > 0:
			_add_level_buff(gem)
	for source in Game.get_gems():
		if  source.under_construction || source.attack.tower_buffs.size() ==0:
			continue
		for target in Game.get_gems():
			if in_range(source, target, source.attack_range.root):
				for buff in source.attack.tower_buffs:
					_apply_tower_buff(target.buffs, buff)
	for gem in Game.get_gems():
		gem.damage.update() 
		gem.attack_range.update()
		gem.attack_delay.update() 

func _add_level_buff(gem : Gem):
	var level_buff = TowerBuff.new()
	level_buff.name = "Level-Up Bonus"
	level_buff.description = "+ " +str(gem.level * LEVEL_DMG_INC * 100)+"% DMG"
	level_buff.attribute = TowerBuff.Attribute.DAMAGE
	level_buff.value = 1 + gem.level * LEVEL_DMG_INC
	level_buff.operation = TowerBuff.Operation.MUL
	gem.buffs.append(level_buff)

func in_range(source : Node2D, target : Node2D, range : float) -> bool:
	return source.global_position.distance_to(target.global_position) <= range/ 2		

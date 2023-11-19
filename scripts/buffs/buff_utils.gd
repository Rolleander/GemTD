extends Node

const LEVEL_DMG_INC = 0.1
#gem size radius
const G_R = 18

func add_enemy_buff (enemy : Enemy, source : Gem,  buff : EnemyBuff) -> bool:	
	if !_remove_existing_enemy_buffs(enemy.buffs, buff):
		return false
	var instance =  EnemyBuffInstance.new(buff, source, enemy)		
	if buff.attribute == EnemyBuff.Attribute.HEALTH:
		instance.target_value = enemy.health
	elif buff.attribute == EnemyBuff.Attribute.ARMOR:
		instance.target_value = enemy.armor
	elif buff.attribute == EnemyBuff.Attribute.SPEED:
		instance.target_value = enemy.speed
	enemy.buffs.append(instance)
	enemy.buffs.sort_custom(_order_enemy_buffs)
	return true

func _remove_existing_enemy_buffs(buffs: Array, buff : EnemyBuff) -> bool:
	var remove = []
	var instances = 0
	for b in buffs:
		if b.buff.stack_group == buff.stack_group:
			if b.buff.priority <= buff.priority:
				instances +=1
				if instances >= buff.stack_size: 
					remove.append(b)
			else:
				return false
	for b in remove:
		buffs.erase(b)
		if b.buff.permanent:
			b.target_value.apply_permanent(b)
	return true
	
func _order_enemy_buffs( a : EnemyBuffInstance, b : EnemyBuffInstance):
	return _order_buffs(a.buff, b.buff)
	
func _apply_tower_buff(buffs: Array, buff : TowerBuff) -> bool:
	if !_remove_existing_tower_buffs(buffs, buff):
		return false
	buffs.append(buff)			
	buffs.sort_custom(_order_buffs)	
	return true
	
func _remove_existing_tower_buffs(buffs : Array, buff : TowerBuff):
	var remove = []
	var instances = 0
	for b in buffs:
		if b.stack_group == buff.stack_group:
			if b.priority <= buff.priority:
				instances +=1
				if instances >= buff.stack_size: 
					remove.append(b)
			else:
				return false
	for r in remove:
		buffs.erase(r)
	return true
	
func _order_buffs( a : Buff, b : Buff):
	return a.order <= b.order

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
			if Utils.in_range(source, target, source.attack_range.root , G_R):
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
	level_buff.value = gem.level * LEVEL_DMG_INC
	level_buff.operation = TowerBuff.Operation.ADD_ROOT_MUL
	gem.buffs.append(level_buff)


extends EnemyBuffableValue
class_name HealthValue

var killer : Gem
var outstanding_damages = []
var remaining_damage_dealt = false

func _init(owner : Enemy, value : float = 0.0):
	self.attribute = EnemyBuff.Attribute.HEALTH
	self.owner = owner
	self.root = value	
	
func update():
	value = root
	outstanding_damages.clear()
	for i in range(owner.buffs.size()-1, -1, -1):
		var instance = owner.buffs[i] as EnemyBuffInstance
		var buff = instance.buff as EnemyBuff
		if killer != null:
			return
		if buff.attribute == attribute:
			if buff.operation == EnemyBuff.Operation.ADD:
				_add_health(instance)
			elif buff.operation == EnemyBuff.Operation.SET:
				value = buff.value
				if instance.done && buff.permanent:
					root = buff.value
			elif buff.operation == EnemyBuff.Operation.MUL:
				value *=  instance.current_value()	
				if instance.done && buff.permanent:
					root *= instance.current_value()
			if instance.done:
				owner.buffs.remove_at(i)
	if value <=0 && !remaining_damage_dealt:
		remaining_damage_dealt = true	
		for dmg in outstanding_damages:
			var damage = dmg.dmg
			var instance = dmg.src
			instance.source.damage_dealt.dealt(damage)
							
func apply_permanent(instance : EnemyBuffInstance):
	var damage =instance.current_value()*-1
	root -= damage
	instance.source.damage_dealt.dealt(damage)

func _add_health(instance : EnemyBuffInstance):
	var add = instance.current_value()
	if add > 0:
		value+=add
		return
	if value <= 0:
		return	
	var damage = minf(value, add *-1)
	value -= damage
	if instance.buff.permanent :
		if instance.done: 
			var source = instance.source
			root -= damage
			if value <=0:
				killer =source	
			instance.source.damage_dealt.dealt(damage)
		else:
			var dmg = { "dmg" : damage, "src" : instance }
			outstanding_damages.append(dmg)


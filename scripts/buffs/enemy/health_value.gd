extends EnemyBuffableValue
class_name HealthValue

var killer : Gem

func _init(owner : Enemy, value : float = 0.0):
	self.attribute = EnemyBuff.Attribute.HEALTH
	self.owner = owner
	self.root = value	
	
func update():
	super()
	for instance in owner.buffs:
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

func apply_permanent(instance : EnemyBuffInstance):
	var damage =instance.current_value()*-1
	root -= damage
	Events.damage_dealt.emit(owner, instance.source, damage)

func _add_health(instance : EnemyBuffInstance):
	var add = instance.current_value()
	if add > 0:
		value+=add
		return
	if value <= 0:
		return	
	var damage = minf(value, add *-1)
	value -= damage
	if (instance.done && instance.buff.permanent) || value ==0:
		var source = instance.source
		root -= damage
		if value ==0:
			killer =source	
		Events.damage_dealt.emit(owner, source, damage)

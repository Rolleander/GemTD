extends BuffableValue
class_name EnemyBuffableValue

var owner : Enemy
var attribute : EnemyBuff.Attribute

func _init(owner : Enemy, attribute : EnemyBuff.Attribute, value : float = 0.0):
	self.owner = owner
	self.root = value	
	self.attribute = attribute
	
func update():
	super()
	for i in range(owner.buffs.size()-1, -1, -1):
		var instance = owner.buffs[i] as EnemyBuffInstance
		var buff = instance.buff as EnemyBuff
		if instance.is_damage_buff():
			continue
		if buff.attribute == attribute:
			if buff.operation == EnemyBuff.Operation.ADD:
				value += instance.current_value()
				if instance.done && buff.permanent:
					apply_permanent(instance)
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
	
func apply_permanent(instance : EnemyBuffInstance):
	if instance.is_damage_buff():
		return
	root += instance.current_value()

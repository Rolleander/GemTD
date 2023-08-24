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
	for instance in owner.buffs:
		var buff = instance.buff as EnemyBuff
		if buff.attribute == attribute:
			if buff.operation == EnemyBuff.Operation.ADD:
				value += instance.current_value()
				if instance.done && buff.permanent:
					root += instance.current_value()
			elif buff.operation == EnemyBuff.Operation.SET:
				value = buff.value
				if instance.done && buff.permanent:
					root = buff.value
			elif buff.operation == EnemyBuff.Operation.MUL:
				value *=  instance.current_value()	
				if instance.done && buff.permanent:
					root *= instance.current_value()

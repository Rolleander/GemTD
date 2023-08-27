extends BuffableValue
class_name TowerBuffableValue

var owner : Gem
var attribute : TowerBuff.Attribute

func _init(owner : Gem, attribute : TowerBuff.Attribute, value : float = 0.0):
	self.owner = owner
	self.root = value	
	self.attribute = attribute
	
func update():
	super()
	for buff in owner.buffs:
		if buff.attribute == attribute:
			if buff.operation == TowerBuff.Operation.ADD:
				value += buff.value
			elif buff.operation == TowerBuff.Operation.SET:
				value = buff.value
			elif buff.operation == TowerBuff.Operation.MUL:
				value *= buff.value
	

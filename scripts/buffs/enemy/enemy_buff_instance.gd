class_name EnemyBuffInstance

var buff : EnemyBuff
var source : Gem
var target : Enemy
var done = false
var progress = 0
var target_value : EnemyBuffableValue
var armor_on_init 

func _init(buff : EnemyBuff, source : Gem, target : Enemy):
	self.buff = buff	
	self.source = source	
	self.target = target
	armor_on_init = target.armor.value

func current_value():
	var value 
	if buff.continous:
		var base = 1 if buff.operation == EnemyBuff.Operation.MUL else 0
		var time = progress / buff.duration
		value= lerpf(base, buff.value,  time)
	else:
		value= buff.value
	if 	buff.attribute == EnemyBuff.Attribute.HEALTH && buff.operation == EnemyBuff.Operation.ADD:
		value = value/ armor_on_init
	return value

func update(delta):
	if buff.duration >0:
		progress+=delta 
		done = progress >= buff.duration	

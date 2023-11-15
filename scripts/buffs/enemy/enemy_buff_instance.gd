class_name EnemyBuffInstance

var buff : EnemyBuff
var source : Gem
var target : Enemy
var done = false
var damageDealt = false
var progress = 0

func current_value():
	var value 
	if buff.continous:
		var base = 1 if buff.operation == EnemyBuff.Operation.MUL else 0
		var time = progress / buff.duration
		value= lerpf(base, buff.value,  time)
	else:
		value= buff.value
	if 	buff.attribute == EnemyBuff.Attribute.HEALTH && buff.operation == EnemyBuff.Operation.ADD:
		value *= target.damage_scale
	return value

func update(delta):
	if buff.duration >0:
		progress+=delta 
		done = progress >= buff.duration
		
func register_damage() -> float:
	if damageDealt || current_value() >=0 || buff.attribute != EnemyBuff.Attribute.HEALTH: 
		return 0
	var damage = current_value() *-1
	Events.emit_signal("damage_dealt", target, source, damage)
	damageDealt = true
	return damage

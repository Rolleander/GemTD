class_name EnemyBuffInstance

var buff : EnemyBuff
var source : Gem
var target : Enemy
var done = false
var progress = 0
var target_value : EnemyBuffableValue

func _init(buff : EnemyBuff, source : Gem, target : Enemy):
	self.buff = buff	
	self.source = source	
	self.target = target

func current_value():
	var value 
	if is_damage_buff():
		value =  (buff.value / buff.duration) / target.armor.value
	elif buff.continous:
		var base = 1 if buff.operation == EnemyBuff.Operation.MUL else 0
		var time = progress / buff.duration
		value= lerpf(base, buff.value,  time)
	else:
		value= buff.value
	return value

func is_damage_buff():
	return buff.value < 0 && buff.permanent && buff.attribute == EnemyBuff.Attribute.HEALTH && buff.operation == EnemyBuff.Operation.ADD

func _track_damage(delta):
	var tick_dmg = target.calc_damage(current_value() * delta * -1, [EnemyBuff.Attribute.PLATING, EnemyBuff.Attribute.LIMITER])
	if tick_dmg > 0:
		target.health.value -= tick_dmg
		target.health.root -= tick_dmg
		if target.health.value <= 0:
			target.killer = source
		source.damage_dealt.dealt(tick_dmg)
	
func update(delta):
	if buff.duration >0:
		progress+=delta 
		done = progress >= buff.duration	
		if progress > buff.duration:
			delta -= progress - buff.duration 
			progress = buff.duration
		if is_damage_buff():
			_track_damage(delta)

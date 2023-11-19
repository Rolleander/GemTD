extends Panel

@onready var name_label = $MarginContainer/VBoxContainer/HBoxContainer/Name
@onready var level_label = $MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var damage_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/AtkValue
@onready var speed_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer2/SpdValue
@onready var range_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/RngValue
@onready var exp_bar = $MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/MarginContainer/ProgressBar as ProgressBar
@onready var kills_label = $MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer/Kills
@onready var buffList = get_parent().get_node("BuffList")
@onready var info_label = $MarginContainer/VBoxContainer/MarginContainer/AttackInfo

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false; buffList.visible = false)
	
func _open(gem : Gem):
	visible =true
	name_label.text = gem.gem_name
	level_label.text = "Lv. "+str(gem.level)
	damage_label.text = _buffed_text(gem.damage)	
	speed_label.text = _buffed_text(gem.attack_delay)	
	range_label.text = _buffed_text(gem.attack_range)	
	exp_bar.tooltip_text = str(gem.exp)+" / "+str(gem.levelup_exp)
	exp_bar.min_value = LevelUp.get_levelup_exp(gem.level)
	exp_bar.max_value = gem.levelup_exp
	exp_bar.value = gem.exp
	kills_label.text = str(gem.kills)
	level_label.visible = !gem.rock
	if gem.rock:
		info_label.text = "Blocks enemies path"
	else:
		var info = gem.attack.description
		for buff in gem.attack.hit_buffs:
			info += "Attacks apply "+_enem_buff_text(buff)+ "\n"
		for buff in gem.attack.aura_buffs:
			info +=  "Enemy aura with "+ _enem_buff_text(buff) + "\n"
		for buff in gem.attack.tower_buffs:
			info += "Gem aura with "+  buff.description + " ["+buff.name+"]\n"		
		info_label.text = info
	
	$MarginContainer/VBoxContainer/HBoxContainer2.visible = !gem.rock
	$MarginContainer/VBoxContainer/HBoxContainer3.visible = !gem.rock
	if !gem.rock:
		buffList.open(gem.buffs)

func _enem_buff_text(buff : EnemyBuff):
	var text =  buff.description
	if buff.duration > 0:
		text += " for "+str(buff.duration)+"s"
	text += " ["+buff.name+"]"
	return text

func _buffed_text(value : BuffableValue):
	var text = str(snappedf( value.value,0.01))
	var buff = value.value - value.root	
	var percent = snappedf( (buff / value.root) * 100, 0.01)
	if buff != 0:
		text+= " ("+str(percent)+"%)"
	return text

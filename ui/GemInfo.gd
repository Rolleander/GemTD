extends Panel

@onready var name_label = $MarginContainer/VBoxContainer/HBoxContainer/Name
@onready var level_label = $MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var damage_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/AtkValue
@onready var speed_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer2/SpdValue
@onready var range_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/RngValue

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)

func _open(gem : Gem):
	visible =true
	name_label.text = gem.gem_name
	level_label.text = "Lv. "+str(gem.level)
	damage_label.text = _buffed_text(gem.damage)	
	speed_label.text = _buffed_text(gem.attack_delay)	
	range_label.text = _buffed_text(gem.attack_range)	
	level_label.visible = !gem.rock
	$MarginContainer/VBoxContainer/HBoxContainer2.visible = !gem.rock
		

func _buffed_text(value : BuffableValue):
	var text = str(snappedf( value.value,0.01))
	var buff = value.value - value.root	
	var percent = snappedf( (buff / value.root) * 100, 0.01)
	if buff != 0:
		text+= " ("+str(percent)+"%)"
	return text

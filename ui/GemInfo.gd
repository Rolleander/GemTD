extends PanelContainer

@onready var name_label = $MarginContainer/VBoxContainer/HBoxContainer/Name
@onready var level_label = $MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var damage_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/AtkValue
@onready var damage_buff_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/AtkBuff as Label
@onready var speed_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer2/SpdValue
@onready var speed_buff_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer2/SpdBuff as Label
@onready var range_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/RngValue
@onready var range_buff_label = $MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/RngBuff as Label
@onready var exp_container = $MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer2
@onready var exp_bar = $MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/MarginContainer/ProgressBar as ProgressBar
@onready var exp_value_label = $MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/MarginContainer/ProgressBar/Value as Label
@onready var kills_label = $MarginContainer/VBoxContainer/HBoxContainer3/HBoxContainer/Kills
@onready var buffList = get_parent().get_node("BuffList")
@onready var info_label = $MarginContainer/VBoxContainer/MarginContainer/AttackInfo

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false; buffList.visible = false)
	
func _open(gem: Gem):
	visible = true
	name_label.text = gem.gem_name
	level_label.text = "Lv. " + str(gem.level)
	_set_buffed_value(damage_label, damage_buff_label, gem.damage)
	_set_buffed_value(speed_label, speed_buff_label, gem.attack_delay, true)
	_set_buffed_value(range_label, range_buff_label, gem.attack_range)
	var show_exp := !gem.rock && gem.level < LevelUp.SHARE_LEVEL
	exp_container.visible = show_exp
	if show_exp:
		exp_bar.tooltip_text = str(gem.exp) + " / " + str(gem.levelup_exp)
		exp_bar.min_value = LevelUp.get_levelup_exp(gem.level)
		exp_bar.max_value = gem.levelup_exp
		exp_bar.value = gem.exp
		exp_value_label.text = "%s/%s" % [
			_format_exp_value(gem.exp),
			_format_exp_value(gem.levelup_exp)
		]
	kills_label.text = str(gem.kills)
	level_label.visible = !gem.rock
	if gem.rock:
		info_label.text = "Blocks enemies path"
	else:
		var info_lines: Array[String] = []
		if !gem.attack.description.is_empty():
			info_lines.append(gem.attack.description)
		for buff in gem.attack.hit_buffs:
			info_lines.append("Attacks apply " + _enem_buff_text(buff))
		for buff in gem.attack.aura_buffs:
			info_lines.append("Enemy aura with " + _enem_buff_text(buff))
		for buff in gem.attack.tower_buffs:
			info_lines.append("Gem aura with " + buff.description + " [" + buff.name + "]")
		info_label.text = "\n".join(info_lines)
	
	$MarginContainer/VBoxContainer/HBoxContainer2.visible = !gem.rock
	$MarginContainer/VBoxContainer/HBoxContainer3.visible = !gem.rock
	if !gem.rock:
		buffList.open(gem.buffs)

func _enem_buff_text(buff: EnemyBuff):
	var text = buff.description
	if buff.duration > 0:
		text += " for " + str(buff.duration) + "s"
	text += " [" + buff.name + "]"
	return text

func _format_exp_value(value: float) -> String:
	return ("%.1f" % value).trim_suffix(".0")

func _set_buffed_value(
	value_label: Label,
	percent_label: Label,
	value: BuffableValue,
	invert_percent: bool = false
) -> void:
	var buffed_value = value.value
	if invert_percent:
		buffed_value = 1.0 / buffed_value
	value_label.text = str(snappedf(buffed_value, 0.01))
	var buff: float = value.value - value.root
	if is_zero_approx(buff) || is_zero_approx(value.root):
		percent_label.visible = false
		return

	var percent: float = snappedf((buff / value.root) * 100, 0.01)
	if invert_percent:
		percent *= -1
	var sign := "+" if percent >= 0 else ""
	percent_label.text = " (" + sign + str(roundi(percent)) + "%)"
	percent_label.visible = true

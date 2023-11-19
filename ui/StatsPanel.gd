extends Panel

@onready var name_label = $MarginContainer2/VBoxContainer/GemTable/GemName
@onready var value_label = $MarginContainer2/VBoxContainer/GemTable/GemValue
@onready var table = $MarginContainer2/VBoxContainer/GemTable

const MAX_ROWS = 10
var tab = 0
var total = 0

func _ready():
	for i in MAX_ROWS:
		var name = name_label.duplicate()
		var value = value_label.duplicate()
		table.add_child(name)		
		table.add_child(value)		
	_fill_stats()
	Events.wave_started.connect(_wave_started)

func _wave_started():
	for gem in Game.get_gems():
		gem.damage_dealt.reset()
	
func _fill_stats():
	var stats = _calc_stats()
	for i in MAX_ROWS:
		var name = table.get_child(i*2+2)
		var value = table.get_child(i*2+3)
		if i < stats.size():
			var stat = stats[i]["value"]
			name.text = stats[i]["name"]
			value.text = str(round(stat))
		else:
			name.text=""
			value.text=""
	table.get_child(0).text = "Total"
	table.get_child(1).text = str(round(total))
	
			
func _calc_stats():
	var stats = []
	total = 0
	for gem in Game.get_gems():
		var value = 0
		if tab == 0:
			value = gem.damage_dealt.total
		if tab == 1:
			value = gem.damage_dealt.dps
		if tab == 2:
			value = gem.kills
		if tab == 3:
			value = gem.level	
		total += value
		stats.append({"name": gem.gem_name,"value" :value })		
	stats.sort_custom(_sort_by_value)
	return stats.slice(0, min(stats.size(), MAX_ROWS))
	
func _sort_by_value(a ,b ):
	return a.value > b.value

func _physics_process(delta):	
	_fill_stats()

func _on_tab_bar_tab_changed(tab):
	self.tab = tab

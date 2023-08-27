extends Panel

@onready var name_label = $MarginContainer2/GemTable/GemName
@onready var value_label = $MarginContainer2/GemTable/GemValue
@onready var table = $MarginContainer2/GemTable

const MAX_ROWS = 10

func _ready():
	for i in MAX_ROWS-1:
		var name = name_label.duplicate()
		var value = value_label.duplicate()
		table.add_child(name)		
		table.add_child(value)		
	_fill_stats()
	Events.damage_dealt.connect(_damage_dealt)
	
func _damage_dealt(enemy: Enemy, gem : Gem, damage : float):
	gem.damage_dealt += damage

func _fill_stats():
	var stats = _calc_damage()
	for i in MAX_ROWS:
		var name = table.get_child(i*2)
		var value = table.get_child(i*2+1)
		if i < stats.size():
			name.text = stats[i]["name"]
			value.text = str(round(stats[i]["value"]))
		else:
			name.text=""
			value.text=""
			
func _calc_damage():
	var stats = []
	for gem in Game.get_gems():
		stats.append({"name": gem.gem_name,"value" : gem.damage_dealt})		
	stats.sort_custom(_sort_by_value)
	return stats.slice(0, min(stats.size(), MAX_ROWS))
	
func _sort_by_value(a ,b ):
	return a.value > b.value
		
func _process(delta):
	_fill_stats()

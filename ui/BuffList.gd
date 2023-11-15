extends VBoxContainer

func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)
	
func _open(gem : Gem):
	if gem.rock:
		return
	visible = true
	for child in  get_children():
		child.queue_free()
	custom_minimum_size.x = 300
	custom_minimum_size.y =  gem.buffs.size() * 30	
	for buff in gem.buffs:
		_create_buff(buff)

func _create_buff(buff : TowerBuff):
	var label = preload("res://ui/BuffDisplay.tscn").instantiate()
	label.get_node("MarginContainer/HBoxContainer/Label").text = buff.name
	label.get_node("MarginContainer/HBoxContainer/Label2").text = buff.description
	add_child(label)
	
#func _physics_process(delta):
	#gem.buffs
	
	

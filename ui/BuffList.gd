extends VBoxContainer

	
func open(buffs : Array):
	visible = true
	for child in  get_children():
		child.queue_free()
	custom_minimum_size.x = 300
	custom_minimum_size.y =  buffs.size() * 30	
	for buff in buffs:
		if buff is TowerBuff:
			_create_tower_buff(buff)
		elif buff is EnemyBuffInstance:
			_create_enemy_buff(buff)	

func _create_enemy_buff(buff : EnemyBuffInstance):
	var duration = -1
	if buff.buff.duration > 0:
		duration = 1-( buff.progress / buff.buff.duration )		
	_create_buff(buff.buff.name, buff.buff.description, duration)

func _create_tower_buff(buff : TowerBuff):
	_create_buff(buff.name, buff.description, -1)

func _create_buff(title : String , text : String, duration : float):
	var label = preload("res://ui/BuffDisplay.tscn").instantiate()
	label.get_node("MarginContainer/HBoxContainer/Label").text = title
	label.get_node("MarginContainer/HBoxContainer/Label2").text = text
	var prog = label.get_node("MarginContainer/HBoxContainer/Duration") as TextureProgressBar
	if duration >= 0:
		prog.value = duration
		prog.visible = true
	else:	
		prog.visible = false
	add_child(label)

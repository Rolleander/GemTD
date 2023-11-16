extends Panel

@onready var buffList = get_parent().get_node("BuffList")
@onready var healthBar = $VBoxContainer/HBoxContainer/MarginContainer/HealthBar as ProgressBar
@onready var healthLabel = $VBoxContainer/HBoxContainer2/HealthLabel

func _ready():
	Events.enemy_selected.connect(_open)
	Events.unselect.connect(func(): visible = false; buffList.visible = false)
	
func _open(enemy : Enemy):
	visible = true	
	_update()
	
func _update():
	var enemy = Game.selected_enemy
	if enemy == null || !enemy.alive:
		visible = false
		buffList.visible =false
		enemy.selection.visible = false
		Game.selected_enemy = null
		return
	healthBar.min_value = 0
	healthBar.max_value = enemy.max_health
	healthBar.value = enemy.health.value
	healthLabel.text = str(roundi( healthBar.value))+" / "+str(healthBar.max_value)
	buffList.open(enemy.buffs)	

func _physics_process(delta):
	if visible:
		_update()

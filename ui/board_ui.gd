extends CanvasLayer

@onready var wave = $MarginContainer5/Panel/HBoxContainer/HBoxContainer/WaveLabel as Label
@onready var money = $MarginContainer5/Panel/HBoxContainer/HBoxContainer2/MoneyLabel as Label
@onready var path = $MarginContainer5/Panel/HBoxContainer/HBoxContainer3/PathLabel as Label
@onready var fps = $FpsLabel as Label

func _ready():
	$MarginContainer2/MarginContainer/GemInfo.visible = false
	$MarginContainer2/MarginContainer/BuildMenu.visible = false
	$MarginContainer2/MarginContainer/RockMenu.visible = false
	$MarginContainer2/MarginContainer/GemMenu.visible = false
	$MarginContainer3/VBoxContainer/EnemyPanel.visible = false
	visible = true

func _process(delta):
	wave.text = str(Game.wave.current + 1)
	money.text = str(Game.money)
	path.text = str(Game.path_length)
	fps.text = "FPS: " + str(Engine.get_frames_per_second())

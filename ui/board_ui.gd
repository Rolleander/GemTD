extends CanvasLayer

@onready var buildingPhaseInfo = $MarginContainer5/VBoxContainer/BuildingPhaseInfo

@onready var wave = $MarginContainer5/VBoxContainer/Panel/HBoxContainer/HBoxContainer/WaveLabel as Label
@onready var money = $MarginContainer5/VBoxContainer/Panel/HBoxContainer/HBoxContainer2/MoneyLabel as Label
@onready var path = $MarginContainer5/VBoxContainer/Panel/HBoxContainer/HBoxContainer3/PathLabel as Label
@onready var placings = $MarginContainer5/VBoxContainer/BuildingPhaseInfo/VBoxContainer/GridContainer/PlacingLabel as Label
@onready var freeRerolls = $MarginContainer5/VBoxContainer/BuildingPhaseInfo/VBoxContainer/GridContainer/FreeRerollLabel as Label

@onready var fps = $FpsLabel as Label

func _ready():
	$MarginContainer2/MarginContainer/GemInfo.visible = false
	$MarginContainer2/MarginContainer/BuildMenu.visible = false
	$MarginContainer2/MarginContainer/RockMenu.visible = false
	$MarginContainer2/MarginContainer/GemMenu.visible = false
	$MarginContainer3/VBoxContainer/EnemyPanel.visible = false
	Events.building_phase_started.connect(_building_phase_started)
	Events.wave_started.connect(_wave_started)
	visible = true

func _process(delta):
	wave.text = str(Game.wave.current + 1)
	money.text = str(Game.money)
	path.text = str(Game.path_length)
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	placings.text = str(Game.remaining_placements) + "/" + str(Game.placements_per_round)
	freeRerolls.text = str(Game.free_rerolls)

func _building_phase_started():
	buildingPhaseInfo.visible = true

func _wave_started():
	buildingPhaseInfo.visible = false

extends CanvasLayer

@onready var buildingPhaseInfo = $MarginContainer5/VBoxContainer/BuildingPhaseInfo
@onready var recipeInfo = $MarginContainer5/VBoxContainer/RecipeInfo as VBoxContainer
@onready var wavePhaseInfo = $MarginContainer5/VBoxContainer/WavePhaseInfo as Panel

@onready var wave = $MarginContainer5/VBoxContainer/Panel/HBoxContainer/HBoxContainer/WaveLabel as Label
@onready var money = $MarginContainer5/VBoxContainer/Panel/HBoxContainer/HBoxContainer2/MoneyLabel as Label
@onready var path = $MarginContainer5/VBoxContainer/Panel/HBoxContainer/HBoxContainer3/PathLabel as Label
@onready var placings = $MarginContainer5/VBoxContainer/BuildingPhaseInfo/VBoxContainer/GridContainer/PlacingLabel as Label
@onready var freeRerolls = $MarginContainer5/VBoxContainer/BuildingPhaseInfo/VBoxContainer/GridContainer/FreeRerollLabel as Label

@onready var waveTitleLabel = $MarginContainer5/VBoxContainer/WavePhaseInfo/VBoxContainer/WaveTitleLabel as Label
@onready var waveDescriptionLabel = $MarginContainer5/VBoxContainer/WavePhaseInfo/VBoxContainer/WaveDescriptionLabel as Label
@onready var enemyCountLabel = $MarginContainer5/VBoxContainer/WavePhaseInfo/VBoxContainer/GridContainer/WaveProgress/EnemyCountLabel as Label
@onready var waveProgress = $MarginContainer5/VBoxContainer/WavePhaseInfo/VBoxContainer/GridContainer/WaveProgress as ProgressBar

@onready var fps = $FpsLabel as Label

func _ready():
	$MarginContainer2/MarginContainer/GemInfo.visible = false
	$MarginContainer2/MarginContainer/BuildMenu.visible = false
	$MarginContainer2/MarginContainer/RockMenu.visible = false
	$MarginContainer2/MarginContainer/GemMenu.visible = false
	$MarginContainer3/VBoxContainer/EnemyPanel.visible = false
	wavePhaseInfo.visible = false
	Events.building_phase_started.connect(_building_phase_started)
	Events.wave_started.connect(_wave_started)
	Events.wave_ended.connect(_wave_ended)
	Events.gem_selected.connect(_gem_selected)
	Events.unselect.connect(_unselect)
	visible = true

func _process(delta):
	wave.text = str(roundi(Game.wave.current + 1))
	money.text = str(roundi(Game.money))
	path.text = str(roundi(Game.path_length))
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	placings.text = str(roundi(Game.remaining_placements)) + "/" + str(roundi(Game.placements_per_round))
	enemyCountLabel.text = str(roundi(Game.wave.alive)) + "/" + str(roundi(Game.wave.spawn_target))
	waveProgress.value = Game.wave.alive
	freeRerolls.text = str(roundi(Game.free_rerolls))

func _building_phase_started():
	buildingPhaseInfo.visible = true

func _wave_started():
	buildingPhaseInfo.visible = false
	wavePhaseInfo.visible = true
	waveTitleLabel.text = "Wave " + str(roundi(Game.wave.current + 1))
	waveDescriptionLabel.text = Game.wave.get_enemy_description()
	waveProgress.max_value = Game.wave.spawn_target
	waveProgress.value = 0

func _wave_ended():
	wavePhaseInfo.visible = false

func _gem_selected(gem: Gem):
	for child in recipeInfo.get_children():
		child.free()
	if gem.special_combination || gem.rock:
		recipeInfo.visible = false
		return
	for special_gem in Globals.get_special_gems():
		for recipe in special_gem.recipe:
			if recipe.quality == gem.quality && recipe.type == gem.type:
				var info = preload("res://ui/combination_info.tscn").instantiate() as CombinationInfo
				info.gem = special_gem
				info.custom_minimum_size.y = 50 + special_gem.recipe.size() * 30
				recipeInfo.add_child(info)
				recipeInfo.visible = true
				
func _unselect():
	recipeInfo.visible = false

extends CanvasLayer

@onready var wave = $WaveLabel as Label
@onready var fps = $FpsLabel as Label

func _ready():
	$MarginContainer2/MarginContainer/GemInfo.visible = false
	$MarginContainer2/MarginContainer/BuildMenu.visible = false
	$MarginContainer2/MarginContainer/RockMenu.visible = false


func _process(delta):
	wave.text = "Wave: "+str(Game.wave)
	fps.text = "FPS: "+str(Engine.get_frames_per_second())

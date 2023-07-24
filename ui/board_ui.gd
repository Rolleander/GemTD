extends CanvasLayer

@onready var wave = $WaveLabel as Label
@onready var fps = $FpsLabel as Label

func _ready():
	pass # Replace with function body.


func _process(delta):
	wave.text = "Wave: "+str(Game.wave)
	fps.text = "FPS: "+str(Engine.get_frames_per_second())

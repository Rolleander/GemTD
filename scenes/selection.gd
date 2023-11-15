extends Node2D

class_name Selection
@onready var area = $Area2D
var marker : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0.5)
	marker = get_parent().find_child("Marker")
	Events.unselect.connect(_unselect)
	Events.field_clicked.connect(_field_clicked)
	Events.gem_selected.connect(_gem_select)
	Events.wave_started.connect(_wave_started)

func _wave_started():
	visible = false
	marker.visible = false
	
func _gem_select(gem : Gem):
	marker.visible = false

func _unselect():
	marker.visible = false
	
func _field_clicked(location : Vector2):
	marker.position = location
	marker.visible = true

func valid_place():
	return !area.has_overlapping_bodies()
	
func _process(delta):
	if Game.construction_phase && Game.remaining_placements > 0:
		var pos = Vector2i((get_global_mouse_position() / Globals.GRID_SIZE).round() ) 
		visible = valid_place()
		position = (pos * Globals.GRID_SIZE) 

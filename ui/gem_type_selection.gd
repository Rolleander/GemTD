extends Control

class_name GemTypeSelection

signal selection_finished

const GEM_TEXTURE = preload("res://sprites/gems/perfect.png")
const FRAME_WIDTH = 64.0

@onready var list = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ItemList as ItemList

var selected_type = -1
var selecting = false

func _ready():
	visible = false
	list.clear()
	var gem_types = Globals.gem_types.duplicate()
	gem_types.sort_custom(func(a: GemTypeInfo, b: GemTypeInfo): return a.type < b.type)
	for type_info in gem_types:
		var atlas = AtlasTexture.new()
		atlas.atlas = GEM_TEXTURE
		atlas.region = Rect2(
			FRAME_WIDTH * type_info.type,
			0.0,
			FRAME_WIDTH,
			GEM_TEXTURE.get_height()
		)
		atlas.filter_clip = true
		list.add_item(type_info.label, atlas)
		var item_index = list.item_count - 1
		list.set_item_metadata(item_index, type_info.type)

func select_type():
	if selecting:
		return -1
	selecting = true
	selected_type = -1
	list.deselect_all()
	visible = true
	move_to_front()
	list.grab_focus()
	await selection_finished
	visible = false
	selecting = false
	return selected_type

func _on_item_selected(index: int):
	if !selecting:
		return
	selected_type = list.get_item_metadata(index)
	selection_finished.emit()

func _gui_input(event: InputEvent):
	# Consume clicks on the modal backdrop. Selection can only finish by choosing
	# one of the ItemList entries.
	if selecting && event is InputEventMouseButton:
		accept_event()

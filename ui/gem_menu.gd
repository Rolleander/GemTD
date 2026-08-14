extends Panel

class_name GemMenu

var action_buttons: Array[CostButton] = []
var gem: Gem
var _action_button_index = 0
var _registered_callbacks: Dictionary = {}


func _ready():
	Events.gem_selected.connect(_open)
	Events.unselect.connect(func(): visible = false)
	for child in $HBoxContainer.get_children():
		if child is Button:
			action_buttons.append(child)

func _open(gem: Gem):
	self.gem = gem
	var is_board_gem = gem.is_in_group("gems") && !gem.is_in_group("building")
	var show_menu = !gem.rock && !gem.under_construction && is_board_gem

	for button in action_buttons:
		if _registered_callbacks.has(button):
			var callback: Callable = _registered_callbacks[button]
			if callback.is_valid() && button.action_pressed.is_connected(callback):
				button.action_pressed.disconnect(callback)
			_registered_callbacks.erase(button)
		button.enabled_type = CostButton.EnabledType.BOTH
		button.type = CostButton.CostType.MONEY
	_action_button_index = 0
	if gem.special_combination:
		_init_special_menu()
	else:
		_init_basic_menu()
	for button in action_buttons:
		button._update_panel()
	for index in range(_action_button_index, action_buttons.size()):
		action_buttons[index].visible = false
	visible = show_menu && action_buttons.any(func(but): return but.visible)

func _init_special_menu():
	gem.special_combination.init_menu(self)

func _init_basic_menu():
	if gem.available_combo:
		var button = register_action_button(func(): gem.activate_combination())
		button.text = "Comb"
		button.cost = 0

func register_action_button(callback: Callable) -> CostButton:
	if _action_button_index >= action_buttons.size():
		printerr("button limit reached")
		return null
	var button = action_buttons[_action_button_index]
	_action_button_index += 1
	button.action_pressed.connect(callback)
	_registered_callbacks[button] = callback
	button.visible = true
	return button

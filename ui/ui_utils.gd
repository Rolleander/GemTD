extends Node

func hide_element(element: Control, hidden: bool = true):
	element.modulate.a = 0.0 if hidden else 1.0
	element.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
		if hidden
		else Control.MOUSE_FILTER_STOP
	)

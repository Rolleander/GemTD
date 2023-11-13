class_name BuffableValue

var value = 0.0
var root = 0.0

func update():
	value = root
	
func value_add(value : float):
	self.root += value

func value_mul(value : float):
	self.root *= value

func value_set(value : float):
	self.root = value


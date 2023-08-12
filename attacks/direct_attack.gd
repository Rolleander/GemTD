extends Attack

class_name DirectAttack

func _ready():
	super()

			
func _attack(target : Enemy):
	_hit(target)
	return true

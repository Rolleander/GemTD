extends Attack

class_name DirectAttack

func _ready():
	super()

			
func _attack(target : Enemy):
	super(target)
	_hit(target)
	return true

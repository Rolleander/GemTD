extends Buff

class_name TowerBuff

enum Operation{
	SET,
	ADD,
	MUL
}

enum Attribute{
	DAMAGE,
	ATTACK_DELAY,
	RANGE
}

@export var value : float = 1
@export var operation : Operation = Operation.ADD
@export var attribute : Attribute
 

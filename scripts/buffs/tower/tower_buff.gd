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
	RANGE,
	EXP_GAIN
}

@export var value : float = 1
@export var operation : Operation = Operation.ADD
@export var attribute : Attribute
 

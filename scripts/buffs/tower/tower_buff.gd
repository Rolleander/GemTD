extends Buff

class_name TowerBuff

enum Operation{
	##overwrites existing value with the provided value
	SET,
	##adds provided value to the existing value
	ADD,
	##multiplies existing values with the provided value
	MUL,
	##adds the product of provided value and root value to the existing value
	ADD_ROOT_MUL
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
 

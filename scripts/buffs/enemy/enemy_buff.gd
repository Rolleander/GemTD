extends Buff

class_name EnemyBuff

enum Operation{
	SET,
	ADD,
	MUL
}

enum Attribute{
	HEALTH,
	SPEED,
	ARMOR
}

@export var duration = 1
@export var value : float = 1
@export var operation : Operation = Operation.ADD
@export var attribute : Attribute
@export var continous : bool  = false

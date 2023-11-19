extends Buff

class_name EnemyBuff

enum Operation{
	##overwrites existing value with the provided value
	SET,
	##adds provided value to the existing value
	ADD,
	##multiplies existing values with the provided value
	MUL,
}

enum Attribute{
	HEALTH,
	SPEED,
	ARMOR,
	PLATING
}

##time in seconds the buff is active, time of 0 means it will stay forever
@export var duration = 1
##value being applied in the operation
@export var value : float = 1
##type of the operation being applied
@export var operation : Operation = Operation.ADD
##which attribute to buff
@export var attribute : Attribute
##if true, applies the value evenly over the buff duration (for set or mul operations)
@export var continous : bool  = false
##if true, the buff will permantly change the root value, even after the buff is replaced or duration ended 
@export var permanent : bool  = false
##range to apply aura buffs, if its 0 then tower range will be used instead
@export var aura_range : float = 0

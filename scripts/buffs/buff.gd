extends Resource

class_name Buff

##name to be displayed
@export var name = ""
##descipriont to be displayed
@export var description = ""
##buffs in the same stack group overwrite each other. empty stack group means the buff will always be added and not overwrite existing instances 
@export var stack_group : String = ""
##how many active buffs in the same stack group are allowed at the same time
@export var stack_size : int = 1
##to control buff overwriting in the same stack group, newer buffs with same or higher priority will overwrite existing buff
@export var priority = 0
##order for buffs being applied to the same attribute, higher values will be applied last
@export var order = 0

extends DirectAttack

class_name TopazAttack

@onready var line = $GPUParticles2D/Line

var lines  = [] 

func _ready():
	super()
	line.width = 0.2 + gem.quality * 0.15
	
func _physics_process(delta):
	super(delta)
	for i in range(lines.size()-1, -1, -1):
		if !is_instance_valid(lines[i]):
			lines.remove_at(i)
			continue
		var line = lines[i]
		line.clear_points()
		line.add_point( line.to_local(self.global_position))		
		line.add_point( Vector2(0,0))
		line.modulate.a-=0.03
			
func _attack(target : Enemy):
	var effect= _hit(target) as GPUParticles2D
	var line = effect.get_child(0) as Line2D
	line.clear_points()
	line.visible = true
	line.add_point( line.to_local(self.global_position))
	line.add_point( line.to_local(target.global_position))
	lines.append(line)
	return true

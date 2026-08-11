extends DirectAttack

class_name TopazAttack

@onready var line = $GPUParticles2D/Line

var lines  = [] 

func _ready():
	super()
	line.width = 0.1 + gem.quality * 0.25
	
func _physics_process(delta):
	super(delta)
	for i in range(lines.size()-1, -1, -1):
		if !is_instance_valid(lines[i]):
			lines.remove_at(i)
			continue
		var line = lines[i]
		var target = line.get_meta("target") as Enemy
		if !is_instance_valid(target):
			line.queue_free()
			lines.remove_at(i)
			continue
		line.clear_points()
		line.add_point(_screen_to_line(line, gem.get_attack_origin_screen_position()))
		line.add_point(_screen_to_line(line, target.get_hit_screen_position()))
		line.modulate.a-=0.03
			
func _attack(target : Enemy):
	var effect= _hit(target) as GPUParticles2D
	# Topaz lightning intentionally remains depth-sorted with its target instead
	# of using the foreground layer reserved for projectile attacks.
	effect.z_as_relative = true
	effect.z_index = 0
	var line = effect.get_child(0) as Line2D
	line.set_meta("target", target)
	line.clear_points()
	line.visible = true
	line.add_point(_screen_to_line(line, gem.get_attack_origin_screen_position()))
	line.add_point(_screen_to_line(line, target.get_hit_screen_position()))
	lines.append(line)
	return true

func _screen_to_line(line: Line2D, screen_position: Vector2) -> Vector2:
	return line.get_global_transform_with_canvas().affine_inverse() * screen_position

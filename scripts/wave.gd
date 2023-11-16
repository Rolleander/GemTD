extends Node

class_name Wave

var waves : Array 
var current = 0
var spawn_target = 0
var spawned = 0
var spawn_timer = Timer.new()
var alive = 0

func _init(file : String):
	waves = preload("res://resources/waves/standard.csv").records	

func _ready():
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_enemy)
	Events.enemy_killed.connect(_enemy_killed)


func start_wave():
	alive = 0
	spawned = 0
	print("waves "+str(waves[current]))
	spawn_target = waves[current].Count
	spawn_timer.start(0.5)
	Events.emit_signal("wave_started")	

func _spawn_enemy():
	var enemies = get_tree().get_first_node_in_group("enemies_node")
	var enemy = preload("res://scenes/enemy.tscn").instantiate() as Enemy
	enemy.waypoints = get_tree().get_first_node_in_group("waypoints").get_children()
	enemy.position = get_tree().get_first_node_in_group("spawn_point").position
	enemy.max_health = waves[current].Health
	var air = waves[current].Enemy == "A"
	enemy.health.value_set( enemy.max_health)
	if air:
		enemy.speed.value_set(75 + current * 1.25)
	else:	
		enemy.speed.value_set(100 + current * 2.5 )
	enemies.add_child(enemy)
	alive +=1
	spawned += 1
	enemy.set_flying(air)
		
	Events.emit_signal("enemy_spawned", enemy)
	if spawned == spawn_target:
		spawn_timer.stop()
				
func _enemy_killed(enemy: Enemy, killer: Gem):
	alive-=1
	if alive == 0 && spawned == spawn_target:
		_wave_ended()	

func _wave_ended():
	current+=1
	Events.emit_signal("wave_ended")

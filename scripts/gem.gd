extends Node2D

class_name Gem

const GemQuality = preload("res://scripts/gem_quality.gd").GemQuality
const GemType = preload("res://scripts/gem_types.gd").GemType
const SPRITE_SIZE = 64
const RANGE_RING = 800.0
@onready var sprite = $Sprite2D
@onready var glow = $Glow
@onready var label = $Label
@onready var labelShadow = $LabelShadow
@onready var selection = $SelectionRing
@onready var range_ring = $RangRing

var glowing = 0
var type : GemType
var quality : GemQuality
var rock = false
var special_combination = false
var kills = 0
var exp = 0
var under_construction = false
var attack : Attack

func _ready():
	Events.wave_started.connect(func():	attack.active = true)
	Events.wave_ended.connect(func():attack.active = false)

func _set_attack(attack : Attack):
	self.attack = attack
	attack.gem = self
	attack.init()
	var range_scale = attack.attack_range / RANGE_RING
	range_ring.scale = Vector2(range_scale, range_scale)
	add_child(attack)
	
func _process(delta):
	glowing +=0.03
	glow.modulate.a = sin(glowing) * 0.05 + 0.05 + 0.13
	pass

func make_rock():
	rock = true
	glow.visible = false
	sprite.region_rect.position = Vector2(0, 6 * SPRITE_SIZE)
	remove_child($GPUParticles2D)
	add_to_group("rocks")
	remove_child(attack)
	
func activate(picked : bool):
	remove_from_group("building")
	remove_child(label)
	remove_child(labelShadow)
	remove_child($BuildingRing)
	under_construction = false
	if picked:			
		add_to_group("gems")		
	else:
		make_rock()

func killed(enemy: Enemy):
	kills+=1

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected", self)
		

extends Node2D

class_name Gem

const GemQuality = preload("res://scripts/gem_quality.gd").GemQuality
const GemType = preload("res://scripts/gem_types.gd").GemType
const Boulder = preload("res://gems/boulder.tscn")
const RANGE_RING = 800.0
@onready var label = $Label
@onready var selection = $SelectionRing
@onready var range_ring = $RangRing
@onready var graphic = $Graphic
@onready var glow = $Glow

var type : GemType 
var quality : GemQuality
var rock = false
var special_combination : SpecialGem
var kills = 0
var exp = 0
var levelup_exp = 10
var level = 0
var under_construction = false
var attack : Attack
var gem_name : String
var damage = TowerBuffableValue.new(self, TowerBuff.Attribute.DAMAGE)
var attack_range = TowerBuffableValue.new(self, TowerBuff.Attribute.RANGE)
var attack_delay = TowerBuffableValue.new(self, TowerBuff.Attribute.ATTACK_DELAY)
var buffs = [] as Array[TowerBuff]
var damage_dealt = DamageCounter.new()

func _ready():
	Events.wave_started.connect(func():	attack.active = true)
	Events.wave_ended.connect(func():attack.active = false)
	add_to_group("gems")		

func _physics_process(delta):
	if rock:
		return
	damage_dealt.update(delta)

func set_attack(attack : Attack):
	if self.attack != null:
		self.attack.queue_free()
	self.attack = attack
	attack.gem = self
	var range_scale = attack.attack_range / RANGE_RING
	range_ring.scale = Vector2(range_scale, range_scale)
	add_child(attack)
	self.damage.value_set(attack.damage)
	self.attack_range.value_set(attack.attack_range)
	self.attack_delay.value_set(attack.attack_delay)

func make_rock():
	rock = true
	gem_name = "Mazing Rock"
	glow.visible = false
	add_to_group("rocks")
	remove_from_group("gems")
	if attack.get_parent() == self:
		remove_child(attack)
	graphic.get_child(0).queue_free()
	graphic.add_child(Boulder.instantiate())
	
func activate(picked : bool):
	remove_from_group("building")
	remove_child(label)
	remove_child($BuildingRing)
	under_construction = false
	if !picked:	
		make_rock()
		
func killed(enemy: Enemy):
	kills+=1
	LevelUp.gain_exp_from(self, enemy)
	Game.reselect()

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected", self)
		

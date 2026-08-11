extends Node2D

class_name Gem

const GemQuality = preload("res://scripts/gem_quality.gd").GemQuality
const GemType = preload("res://scripts/gem_types.gd").GemType
const Boulder = preload("res://gems/boulder.tscn")
const RANGE_RING = 800.0
@onready var billboard = $Billboard
@onready var label = $Billboard/Label
@onready var selection = $SelectionRing
@onready var range_ring = $RangRing
@onready var graphic = $Billboard/Graphic
@onready var glow = $Billboard/Glow
@onready var board = get_tree().get_first_node_in_group("board") as Board

var type: GemType
var quality: GemQuality
var rock = false
var special_combination: SpecialGemScene = null
var kills = 0
var exp = 0
var levelup_exp = 10
var level = 0
var under_construction = false
var attack: Attack
var gem_name: String
var damage = TowerBuffableValue.new(self, TowerBuff.Attribute.DAMAGE)
var attack_range = TowerBuffableValue.new(self, TowerBuff.Attribute.RANGE)
var attack_delay = TowerBuffableValue.new(self, TowerBuff.Attribute.ATTACK_DELAY)
var buffs = [] as Array[TowerBuff]
var damage_dealt = DamageCounter.new()
var available_combo: GemCombine = null

func _ready():
	Events.wave_started.connect(func():
		if is_instance_valid(attack):
			attack.active = true
	)
	Events.wave_ended.connect(func():
		if is_instance_valid(attack):
			attack.active = false
	)

func _physics_process(delta):
	if rock:
		return
	damage_dealt.update(delta)

func sync_billboard():
	pass

func refresh_billboard_effects():
	pass

func get_attack_origin_screen_position() -> Vector2:
	return get_viewport().get_canvas_transform() * global_position

func get_attack_origin_world_position() -> Vector2:
	return global_position

func update_level_visual():
	pass

func set_attack(new_attack: Attack):
	var was_active := is_instance_valid(attack) && attack.active
	_destroy_attack()
	attack = new_attack
	attack.gem = self
	self.damage.value_set(attack.damage)
	self.attack_range.value_set(attack.attack_range)
	self.attack_delay.value_set(attack.attack_delay)
	attack.active = was_active
	var range_scale = (attack.attack_range * Globals.TILE_SIZE) / RANGE_RING
	range_ring.scale = Vector2(range_scale, range_scale)
	add_child(attack)

func make_rock():
	rock = true
	gem_name = "Mazing Rock"
	glow.visible = false
	add_to_group("rocks")
	remove_from_group("gems")
	_destroy_attack()
	graphic.get_child(0).queue_free()
	graphic.add_child(Boulder.instantiate())

func _destroy_attack():
	if !is_instance_valid(attack):
		attack = null
		return
	var projectile_attack := attack as ProjectileAttack
	if projectile_attack != null:
		projectile_attack.cancel_projectiles()
	attack.queue_free()
	attack = null
	self.damage.value_set(0)
	self.attack_range.value_set(0)
	self.attack_delay.value_set(0)

func activate_combination():
	if !available_combo:
		return
	var selected_combo = available_combo
	var combination_name = selected_combo.combination.name
	selected_combo.combine(self)
	Events.screen_text("Combined to " + combination_name, Color.LIME_GREEN, 70)
	Game.reselect()

func activate(picked: bool):
	remove_from_group("building")
	label.get_parent().remove_child(label)
	remove_child($BuildingRing)
	under_construction = false
	if picked:
		add_to_group("gems")
	else:
		make_rock()
		
func killed(enemy: Enemy):
	kills += 1
	LevelUp.gain_exp_from(self, enemy)
	Game.reselect()

func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		emit_signal("selected", self)

class_name Enemy extends Node2D

@export var possible_actions: Array[EnemyAction]

@onready var state_machine: StateMachine = $StateMachine
@onready var intent_icon: TextureRect = $IntentIcon
@onready var intent_label: Label = $IntentLabel

@export var max_hp: int = 100
var current_hp: int

@onready var hp_label = $HPLabel
var is_defending: bool = false

signal died

var current_action: EnemyAction
var battle_manager

func _ready():
	current_hp = max_hp
	update_ui()
	state_machine.start_machine([
		EnemyChooseState.new(self),
		EnemyShowIntentState.new(self),
		EnemyActState.new(self)
	])

func take_damage(amount: int):
	var final_damage = amount
	
	if is_defending:
		final_damage = amount / 2
		is_defending = false

	current_hp -= final_damage
	update_ui()
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_hp <= 0:
		die()
		
func update_ui():
	hp_label.text = str(current_hp) + " / " + str(max_hp)

func die():
	died.emit()
	queue_free()

func pick_action() -> EnemyAction:
	return possible_actions.pick_random()
	
func show_intent():
	intent_icon.texture = current_action.intent_icon
	if(current_action.base_value > 0):
		intent_label.text = str(current_action.base_value)

func hide_intent():
	intent_icon.texture = null

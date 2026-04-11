class_name Enemy extends Node2D

@export var data: EnemyData

@onready var state_machine: StateMachine = $StateMachine
@onready var intent_icon: TextureRect = $IntentIcon
@onready var intent_label: Label = $IntentLabel
@onready var ghost_bar: TextureProgressBar = $GhostBar
@onready var health_bar: TextureProgressBar = $HealthBar

var ghost_tween: Tween



var current_hp: int

@onready var hp_label = $HPLabel

signal died(enemy_node: Enemy)
signal enemy_clicked(enemy_node: Enemy)

var current_action: EnemyAction
var battle_manager

func _ready():
	if data:
		ghost_bar.max_value = data.max_hp 
		health_bar.max_value = data.max_hp

		ghost_bar.value = data.max_hp
		health_bar.value = data.max_hp
		print('The maximum value of the HP Bar is: ', health_bar.max_value)
		setup_enemy()
	
func setup_enemy():
	current_hp = data.max_hp
	update_ui()
	$Sprite2D.texture = data.sprite_texture
	state_machine.start_machine([
		EnemyChooseState.new(self),
		EnemyShowIntentState.new(self),
		EnemyActState.new(self)
	])

func take_damage(amount: int):
	var final_damage = amount
	
	if current_action.name == 'Defend':
		final_damage = amount / 2

	current_hp -= final_damage
	health_bar.value = current_hp
	print('The aximum value of the HP Bar after getting hit is : ', health_bar.max_value)
	print('The value of the HP Bar after getting hit is : ', health_bar.value)
	if ghost_tween and ghost_tween.is_running():
		ghost_tween.kill()
		
	ghost_tween = create_tween()
	
	ghost_tween.tween_interval(0.2)
	
	ghost_tween.tween_property(ghost_bar, "value", current_hp, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	update_ui()
	
	self.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	self.modulate = Color.WHITE
	
	if current_hp <= 0:
		die()
		
func update_ui():
	hp_label.text = str(current_hp) + " / " + str(data.max_hp)

func die():
	died.emit(self)
	queue_free()

func pick_action() -> EnemyAction:
	return data.actions.pick_random()
	
func show_intent():
	intent_icon.texture = current_action.intent_icon
	if(current_action.base_value > 0):
		intent_label.text = str(current_action.base_value)
	else:
		intent_label.text = ''

func hide_intent():
	intent_icon.texture = null


func _on_enemy_pressed() -> void:
	print('The enemy clicked was', data.enemy_name)
	enemy_clicked.emit(self)

class_name Enemy extends Node2D

@export var data: EnemyData

@onready var state_machine: StateMachine = $StateMachine
@onready var intent_icon: TextureRect = $EnemyUI/IntentIcon
@onready var intent_label: Label = $EnemyUI/IntentLabel
@onready var ghost_bar: TextureProgressBar = $EnemyUI/GhostBar
@onready var health_bar: TextureProgressBar = $EnemyUI/HealthBar
@onready var hp_label = $EnemyUI/HPLabel
@onready var sprite: Sprite2D = $Sprite2D
@onready var ui_container: Control = $EnemyUI
@onready var enemy_texture_button: TextureButton = $EnemyTextureButton

var ghost_tween: Tween

var current_hp: int
var current_action_index: int
var damage_modifier: float = 1.0
var powerup_modifier: float = 1.0

signal died(enemy_node: Enemy)
signal enemy_clicked(enemy_node: Enemy)

var current_actions: Array[EnemyAction]
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
	sprite.texture = data.sprite_texture
	_align_ui_to_enemy()
	current_action_index = 0
	state_machine.start_machine([
		EnemyChooseState.new(self),
		EnemyShowIntentState.new(self),
		EnemyActState.new(self)
	])

func take_damage(amount: int):
	var final_damage = amount
	
	final_damage = final_damage * damage_modifier

	current_hp -= final_damage
	health_bar.value = current_hp
	print('The maximum value of the HP Bar after getting hit is : ', health_bar.max_value)
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

func _align_ui_to_enemy():
	var texture_height = sprite.texture.get_size().y
	var texture_width = sprite.texture.get_size().x
	var actual_height = texture_height * sprite.scale.y
	var actual_width = texture_width * sprite.scale.x
	
	var head_y_position = -(actual_height / 2.0)
	ui_container.position.y = head_y_position - 60 
	ui_container.position.x = - (ui_container.size.x / 2.0)
	enemy_texture_button.size = Vector2(actual_width, actual_height)
	enemy_texture_button.position = Vector2(-(actual_width / 2.0), -(actual_height / 2.0))
	print('The textures height is: ', texture_height)
	print('The texture_width is: ', texture_width)
	print('The actual_height is: ', actual_height)
	print('The actual_width is: ', actual_width)
	print('The Ui Container,s position is: ', ui_container.position.y )
	
func die():
	died.emit(self)
	queue_free()

func pick_actions() -> Array[EnemyAction]:
	return data.actions
	
func show_intent():
	var current_action = current_actions[current_action_index]
	intent_icon.texture = current_action.intent_icon
	
	var final_base_value = current_action.get_true_base_value(self)
	
	if final_base_value > 0:
		intent_label.text = str(final_base_value)
	else:
		intent_label.text = ''

func hide_intent():
	intent_icon.texture = null


func _on_enemy_pressed() -> void:
	print('The enemy clicked was', data.enemy_name)
	enemy_clicked.emit(self)

class_name RewardScreen extends Control

@onready var item_display_scene = preload("res://scenes/ui/item_display.tscn")
@onready var reward_container = $RewardContainer
@onready var reward_label = $RewardLabel
@onready var reroll_button = $RerollButton
@onready var reroll_label = $RerollLabel


var current_rewards: int = 0
var max_rewards: int = 2
var amount_rerolls: int = 1
var rewardsArray: Array[ItemData]

signal reward_selected(item: ItemData)
signal reroll_selected(reroll_amount: int, current_reward: int, max_reward: int)

var data: ItemData

func set_rewards(items: Array[ItemData], allowed_amount_rewards: int = 2):
	current_rewards = 0
	max_rewards = allowed_amount_rewards
	rewardsArray.clear()
	
	amount_rerolls = 1
	reroll_label.text = 'Rerolls 0/1'
	
	reward_label.text = 'Rewards Collected %d/%d' % [current_rewards, max_rewards]
	
	for child in reward_container.get_children():
			child.queue_free()
			
	if not reroll_button.pressed.is_connected(_on_reroll_button_clicked):
		reroll_button.pressed.connect(_on_reroll_button_clicked)
	

	for item_data in items:
		var reward_button = item_display_scene.instantiate()
		reward_container.add_child(reward_button)
		reward_button.setup(item_data)
		reward_button.item_selected.connect(_on_button_clicked.bind(reward_button))
	show()
		
func _on_button_clicked( item: ItemData, reward_button: ItemDisplay):
	rewardsArray.append(item)
	reward_button.queue_free()
	
	current_rewards += 1
	reward_label.text = 'Rewards Collected %d/%d' % [current_rewards, max_rewards]
	
	if current_rewards >= max_rewards:
		reward_selected.emit(rewardsArray)
		hide()

func _on_reroll_button_clicked():
	reroll_selected.emit(amount_rerolls, current_rewards, max_rewards)
	reroll_label.text = 'Rerolls 1/1'
	amount_rerolls += 1
		

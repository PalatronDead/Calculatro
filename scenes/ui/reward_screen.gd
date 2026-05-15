class_name RewardScreen extends Control

@onready var item_display_scene = preload("res://scenes/ui/item_display.tscn")
@onready var reward_container = $RewardContainer
@onready var reward_label = $RewardLabel
@onready var reroll_button = $RerollButton
@onready var reroll_label = $RerollLabel
@onready var shop_button = $ShopButton
@onready var next_battle_button = $NextBattleButton
@onready var title_label = $TitleLabel
@onready var route_label = $RouteLabel


var current_rewards: int = 0
var max_rewards: int = 2
var amount_rerolls: int = 1
var rewardsArray: Array[ItemData]

signal reward_selected(items: Array[ItemData])
signal reroll_selected(reroll_amount: int, current_reward: int, max_reward: int)
signal route_selected(route: String)

var data: ItemData

func set_rewards(items: Array[ItemData], allowed_amount_rewards: int = 2, is_reroll: bool = false):
	if not is_reroll:
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
	
	shop_button.hide()
	next_battle_button.hide()
	route_label.hide()
	reward_container.show()
	reroll_button.show()
	title_label.show()
	reroll_label.show()
	show()
		
func _on_button_clicked( item: ItemData, reward_button: ItemDisplay):
	rewardsArray.append(item)
	reward_button.queue_free()
	
	current_rewards += 1
	reward_label.text = 'Rewards Collected %d/%d' % [current_rewards, max_rewards]
	
	if current_rewards >= max_rewards:
		reward_selected.emit(rewardsArray)
		reward_container.hide()
		reroll_button.hide()
		reroll_label.hide()
		reward_label.hide()
		title_label.hide()
		shop_button.show()
		next_battle_button.show()
		route_label.show()

func _on_reroll_button_clicked():
	reroll_selected.emit(amount_rerolls, current_rewards, max_rewards)
	reroll_label.text = 'Rerolls 1/1'
	amount_rerolls += 1
		


func _on_shop_button_pressed() -> void:
	hide()
	route_selected.emit('shop')


func _on_next_battle_button_pressed() -> void:
	hide()
	route_selected.emit('shop')

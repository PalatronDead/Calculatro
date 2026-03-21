class_name RewardScreen extends Control

@onready var item_display_scene = preload("res://scenes/ui/item_display.tscn")
@onready var reward_container = $RewardContainer
@onready var reward_label = $RewardLabel
@onready var reroll_button = $RerollButton
@onready var reroll_label = $RerollLabel

var amountOfRewards: int = 1
var amountOfRerolls: int = 1
var rewardsArray: Array[ItemData]

signal reward_selected(item: ItemData)
signal reroll_selected(rerollAmount: int)

var data: ItemData

func set_rewards(items: Array[ItemData]):
	for child in reward_container.get_children():
			child.queue_free()
	
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
	if(amountOfRewards == 1):
		reward_label.text = 'Rewards Collected 1/2'
		amountOfRewards += 1
	else:
		reward_label.text = 'Rewards Collected 2/2'
		reward_selected.emit(rewardsArray)
		amountOfRewards = 1
		hide()

func _on_reroll_button_clicked():
	reroll_selected.emit(amountOfRerolls)
	reroll_label.text = 'Rerolls 1/1'
	amountOfRerolls += 1
		

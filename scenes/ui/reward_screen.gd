class_name RewardScreen extends Control

@onready var item_display_scene = preload("res://scenes/ui/item_display.tscn")
@onready var reward_container = $RewardContainer

signal reward_selected(item: ItemData)

var data: ItemData

func set_rewards(items: Array[ItemData]):
	for child in reward_container.get_children():
			child.queue_free()
	

	for item_data in items:
		var reward_button = item_display_scene.instantiate()
		reward_container.add_child(reward_button)
		reward_button.setup(item_data)
		reward_button.item_selected.connect(_on_button_clicked)
	show()
		
func _on_button_clicked(item: ItemData):
	reward_selected.emit(item)
	hide()
		

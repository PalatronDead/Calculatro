class_name ShopScreen extends Control

@onready var show_item_display_scene = preload("res://scenes/ui/shop_item_display.tscn")
@onready var shop_items_container = $ShopItemsContainer
@onready var currency_label = $CurrencyLabel
@onready var next_battle_button = $NextBattleButton
signal next_battle

func _ready():
	hide()

func open_shop(shop_items: Array[PassiveItemData]):
	_update_money_ui(RunManager.current_currency)
	
	for child in shop_items_container.get_children():
		child.queue_free()

	for item in shop_items:
		var shop_item_button = show_item_display_scene.instantiate()
		shop_items_container.add_child(shop_item_button)
		shop_item_button.setup(item)
		shop_item_button.shop_item_selected.connect(_on_button_clicked.bind(shop_item_button))
	
	show()
	
func _on_button_clicked(item_data: PassiveItemData, shop_item_button: ShopItemDisplay):
	if RunManager.current_currency >= item_data.cost:
		
		RunManager.add_passive_item(item_data)
		
		RunManager.spend_currency(item_data.cost)
		
		_update_money_ui(RunManager.current_currency)
		
		shop_item_button.queue_free()
		
	else:
		print('CANT BUY HAHAHA')
		print('couldnt buy it because your money amount is: ', RunManager.current_currency)

func _update_money_ui(money: int):
	currency_label.text = "Money: " + str(money)
	
func _on_next_battle_button_pressed() -> void:
	next_battle.emit()
	hide()

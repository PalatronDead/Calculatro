extends Node

var max_hp: int = 50
var current_hp: int
var deck: Array[ItemData] = []
var runDeck: Array[ItemData] = []
var chaos_level: int = 0 : set = _on_chaos_level_changed
var current_currency: int = 0
var current_items: Array[PassiveItemData] = []

signal hp_changed(new_amount)
signal deck_changed
signal currency_changed
signal item_added(passiveItem: PassiveItemData)
signal chaos_level_changed

func _ready():
	start_new_run()

func start_new_run():
	current_hp = max_hp
	current_currency = 0
	deck = [
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_three.tres"),
	preload("res://resources/number_three.tres"),
	preload("res://resources/number_four.tres"),
	preload("res://resources/number_four.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
]
	runDeck = deck.duplicate()
	
func add_item_to_deck(itemArray: Array[ItemData]):
	deck.append_array(itemArray)
	print("This are the rewards that were picked: " ,itemArray)
	print('This is the deck after taking the rewards: ', deck)
	runDeck.append_array(itemArray)
	deck_changed.emit()

func modifiy_hp(amount: int):
	print("RunManager received heal request for: ", amount)
	current_hp = clamp(current_hp + amount, 0, max_hp)
	hp_changed.emit(current_hp)
	print("Player HP is now: ", current_hp)
	
func shuffle_deck(deck: Array[ItemData]) -> Array[ItemData]:
	deck.shuffle()
	return deck

func return_deck_after_losing_it_all():
	chaos_level += 1
	print("Chaos level is now at: ", chaos_level, ", you FOOL")

	deck = runDeck.duplicate()
	return deck

func add_currency(currency: int):
	current_currency += currency
	currency_changed.emit(current_currency)
	
func add_passive_item(passive_item: PassiveItemData):
	current_items.append(passive_item)
	item_added.emit(passive_item)
	print('New item has been added, the name is: ' , passive_item.name)

func spend_currency(amount: int):
	current_currency -= amount
	currency_changed.emit(current_currency)

func _on_chaos_level_changed(level):
		chaos_level = level
		chaos_level_changed.emit()
		if chaos_level == 3:
			print("Chaos level reached 3, suffer the CONSEQUENCES")
			current_hp = current_hp / 2
			hp_changed.emit(current_hp)
			chaos_level = 0
			
		
		

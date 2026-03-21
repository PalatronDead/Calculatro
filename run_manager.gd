extends Node

var max_hp: int = 100
var current_hp: int = 100
var deck: Array[ItemData] = []
var runDeck: Array[ItemData] = []

signal hp_changed(new_amount)
signal deck_changed

func _ready():
	start_new_run()

func start_new_run():
	current_hp = max_hp
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
	runDeck.append_array(itemArray)
	deck_changed.emit()

func modifiy_hp(amount: int):
	current_hp += amount
	hp_changed.emit(current_hp)
	
func shuffle_deck(deck: Array[ItemData]) -> Array[ItemData]:
	deck.shuffle()
	return deck

func return_deck_after_losing_it_all():
	deck = runDeck.duplicate()
	return deck

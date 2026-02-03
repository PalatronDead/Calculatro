extends Control

@export var hand_slots: Control
@export var equation_container:HBoxContainer
@export var execute_button : Button
@export var calculator_logic: Node
@export var end_turn_button: Button

signal attack_made(damage_amount: int)
signal turn_ended

var current_hand_data: Array[ItemData] = []

func start_turn(full_deck: Array[ItemData]):
	var new_hand: Array[ItemData] = []
	var deck_copy = full_deck.duplicate()
	deck_copy.shuffle()
	
	for i in range(min(7, deck_copy.size())):
		new_hand.append(deck_copy[i])
	
	draw_hand(new_hand)

func draw_hand(hand_items: Array[ItemData]):
	current_hand_data = hand_items
	_clear_ui()
	
	var slots = hand_slots.get_children()
	
	for i in range(hand_items.size()):
		if i >= slots.size(): break
		
		var item_data = hand_items[i]
		var slot = slots[i]
		
		var btn = preload("res://scenes/ui/item_display.tscn").instantiate()
		slot.add_child(btn)
		
		btn.setup(item_data)
		btn.item_selected.connect(_on_hand_item_clicked.bind(btn))

func _ready() -> void:
	execute_button.pressed.connect(_on_execute_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)

func _on_hand_item_clicked(data: ItemData, button_instance: ItemDisplay):
	button_instance.get_parent().remove_child(button_instance)
	equation_container.add_child(button_instance)
	button_instance.item_selected.disconnect(_on_hand_item_clicked)
	button_instance.item_selected.connect(_return_to_hand.bind(button_instance))
	SoundManager.play_sfx(preload("res://sfx/blipSelect.wav"))

func _return_to_hand(data: ItemData, button_instance: ItemDisplay):
	var empty_slot = _get_first_empty_hand_slot()
	if empty_slot:
		button_instance.get_parent().remove_child(button_instance)
		empty_slot.add_child(button_instance)
		button_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
		button_instance.offset_left = 0
		button_instance.offset_top = 0
		button_instance.offset_right = 0
		button_instance.offset_bottom = 0
		button_instance.item_selected.disconnect(_return_to_hand)
		button_instance.item_selected.connect(_on_hand_item_clicked.bind(button_instance))

func _on_execute_pressed():
	var sequence_data: Array[ItemData] = []
	
	for button in equation_container.get_children():
		if button is ItemDisplay:
			sequence_data.append(button.data)

	var damage = calculator_logic.calculate_sequence(sequence_data)
	
	if damage > 0:
		attack_made.emit(damage)
		_clear_equation()
	else:
		print("Invalid Equation")
		apply_shake()

func _clear_ui():
	_clear_equation()
	for slot in hand_slots.get_children():
		for child in slot.get_children():
			child.queue_free()

func _on_end_turn_pressed():
	turn_ended.emit()
	
func _clear_equation(): 
	for child in equation_container.get_children():
		child.queue_free()
		
func add_to_deck(new_item: ItemData):
	RunManager.deck_pool.append(new_item)

func apply_shake():
	var tween = create_tween()
	
	tween.tween_property(self, "position:x", 10.0, 0.05).as_relative()
	tween.tween_property(self, "position:x", -20.0, 0.05).as_relative()
	tween.tween_property(self, "position:x", 10.0, 0.05).as_relative()
	
	
func _get_first_empty_hand_slot() -> Control:
	for slot in hand_slots.get_children():
		if slot.get_child_count() == 0:
			return slot
	return null

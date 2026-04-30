extends Control

@export var hand_slots: Control
@export var equation_container:HBoxContainer
@export var execute_button : Button
@export var calculator_logic: Node
@export var end_turn_button: Button
@export var player_hp_label: Label
@export var player_hp_sprite: AnimatedSprite2D
@export var camera: Camera2D
@export var player_hp_particle: CPUParticles2D
@export var chaos_orb_container:HBoxContainer
@export var chaos_orb_scene: PackedScene

signal equation_made
signal turn_ended

var current_hand_data: Array[ItemData] = []

func _ready() -> void:
	execute_button.pressed.connect(_on_execute_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	RunManager.hp_changed.connect(_update_player_ui)
	RunManager.chaos_level_changed.connect(_on_chaos_level_changed)

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
	equation_made.emit()

func _on_end_turn_pressed():
	turn_ended.emit()
	
func _update_player_ui(new_hp : int):
	player_hp_label.text = "PLAYER HP: " +  str(new_hp)
	var hp_percentage: float = float(new_hp) / float(RunManager.max_hp)
	
	if hp_percentage > 0.75:
		player_hp_sprite.frame = 0
		if hp_percentage == 1:
			return
		player_hp_particle.emitting = true
	elif hp_percentage > 0.50:
		player_hp_sprite.frame = 1 
		camera.apply_shake(25.0)
		player_hp_particle.emitting = true
	elif hp_percentage > 0.25:
		player_hp_sprite.frame = 2 
		camera.apply_shake(25.0)
		player_hp_particle.emitting = true
	elif hp_percentage > 0.01:
		player_hp_sprite.frame = 3 
		camera.apply_shake(25.0)
		player_hp_particle.emitting = true
	else:
		player_hp_sprite.frame = 4
		camera.apply_shake(50.0)
		player_hp_particle.emitting = true
		
func _clear_ui():
	_clear_equation()
	for slot in hand_slots.get_children():
		for child in slot.get_children():
			child.queue_free()
	
func _clear_equation(): 
	for child in equation_container.get_children():
		child.queue_free()
		
func add_to_deck(new_item: ItemData):
	RunManager.deck_pool.append(new_item)
	
func _on_chaos_level_changed():
	var chaos_orb = chaos_orb_scene.instantiate()
	chaos_orb_container.add_child(chaos_orb)
	
func _get_first_empty_hand_slot() -> Control:
	for slot in hand_slots.get_children():
		if slot.get_child_count() == 0:
			return slot
	return null

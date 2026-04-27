extends Node

@export var calculator_ui: Control
@export var spawn_point: Marker2D
@export var player_hp_label: Label
@export var reward_screen: Control
@export var enemy_scene: PackedScene
@export var encounter_type: Array[EncounterData]
@export var marker_array: Array[Marker2D]
@export var camera: Camera2D
@export var shop_screen: Control

@export var calculator_logic: Node

var roulette_wheel = {"effect_chaos_plus_one": 100, "effect_chaos_spike": 20, "effect_chaos_chaos": 10}

var number_of_targets: int = 0
var clicked_targets: Array[Node] = []

var wait_payload: AttackPayload

var current_enemies: Array = []

@export var max_player_hp: int = 100
var current_player_hp: int

var shake_strength: float = 0

func _ready() -> void:
	calculator_ui._update_player_ui(RunManager.current_hp)
	shop_screen.next_battle.connect(_on_next_battle)
	calculator_ui.equation_made.connect(_on_equation_made)
	calculator_ui.turn_ended.connect(_on_turn_ended)
	reward_screen.reroll_selected.connect(_on_reroll_selected)
	
	RunManager.item_added.connect(_on_item_added)
	start_battle()

func start_battle():
	spawn_new_enemy()
	calculator_ui.start_turn(RunManager.deck)
	
func spawn_new_enemy():
	var random_encounter = encounter_type.pick_random()
	for i in random_encounter.encounter_enemies.size():
		var new_enemy = enemy_scene.instantiate()
		new_enemy.battle_manager = self
		new_enemy.data = random_encounter.encounter_enemies[i]
		new_enemy.global_position = marker_array[i].global_position
		new_enemy.enemy_clicked.connect(_on_enemy_clicked)
		new_enemy.died.connect(_on_enemy_died)
		add_child(new_enemy)
		current_enemies.append(new_enemy)

func _on_player_attack(payload: AttackPayload):
	wait_payload = payload
	number_of_targets = min(payload.aoe_targets, current_enemies.size())
	clicked_targets.clear()
		

func _on_equation_made():
	var items_used = calculator_ui.equation_container.get_children()

	var sequence_data: Array[ItemData] = []
	
	for item in items_used:
		if item is ItemDisplay:
			sequence_data.append(item.data)
			print(item.data)
			
	for i in range(sequence_data.size() - 1):
		if sequence_data[i].display_name == '/' and sequence_data[i + 1].display_name == '0':
			execute_zero_roulette()
			return
		
			
	var damage_payload = calculator_logic.calculate_sequence(sequence_data)
	
	print("Damage: ", damage_payload.base_damage, " | Hits: ", damage_payload.hit_count, " | Lifesteal: ", damage_payload.lifesteal_amount)
	print("the sequence of data is: ", sequence_data)
			
	if damage_payload.base_damage > 0 && calculator_logic.operator_clicked == true:
		_on_player_attack(damage_payload)
		calculator_ui._clear_equation()
		calculator_logic.operator_clicked = false
		for item in items_used:
			if item is ItemDisplay:
				var data: ItemData = item.data
				RunManager.deck.erase(data)
				item.queue_free()
	else:
		print("Invalid Equation")
		camera.apply_shake(2.5)

func take_damage(amount: int):
	RunManager.modifiy_hp(-amount)
	calculator_ui._update_player_ui(RunManager.current_hp)
	camera.apply_shake(15.0)
	SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
	
	if RunManager.current_hp <= 0:
		game_over()

func execute_zero_roulette():
	var total_weight: int = 0
	for roulette_item in roulette_wheel:
		total_weight += roulette_wheel[roulette_item]
	var loot_number = randi_range(1, total_weight)
	for roulette_item in roulette_wheel:
		loot_number -= roulette_wheel[roulette_item]
		if(loot_number <= 0):
			call(roulette_item)
			return

func effect_chaos_chaos():
	RunManager.chaos_level = max(0, RunManager.chaos_level - 1)
	RunManager.current_hp = randi_range(1, RunManager.max_hp)
	calculator_ui._update_player_ui(RunManager.current_hp)
	for enemy in current_enemies:
		enemy.current_hp = randi_range(1, enemy.data.max_hp)
		enemy.update_ui()
	camera.apply_shake(30.0)
	

func effect_chaos_plus_one():
	RunManager.chaos_level += 1
	_on_turn_ended()
	print('Chaos plus one, dummy, currently at: ', RunManager.chaos_level)
	camera.apply_shake(25.0)

func effect_chaos_spike():
	calculator_ui._clear_equation()
	RunManager.chaos_level = 3
	calculator_ui.hide()
	for enemy in current_enemies:
		enemy.hide()
	var random_reward: Array[ItemData] = []
	for i in range(5):
		random_reward.append(LootManager.manage_loot(preload("res://resources/loot_table_world1.tres")).item)
	reward_screen.set_rewards(random_reward, 5)
	var selection = await reward_screen.reward_selected
	RunManager.add_item_to_deck(selection)
	print('Bro got chaos spiked, i cant: ', RunManager.chaos_level)
	calculator_ui.show()
	for enemy in current_enemies:
		enemy.show()
	SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
	camera.apply_shake(40.0)

func _on_turn_ended():
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			if enemy.current_hp > 0:
				enemy.state_machine.transition("Act")
	if(RunManager.deck.size() >= 1):
		var number_of_numbers: int
		var number_of_operators: int
		for token in RunManager.deck:
			if token.type == ItemData.Type.INTEGER:
				number_of_numbers += 1
			elif token.type == ItemData.Type.OPERATOR:
				number_of_operators += 1
		if number_of_numbers >= 2 && number_of_operators >=1:
			calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))
			print("Shuffleando los shuffles")
		else:
			calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.return_deck_after_losing_it_all()))
		
	else:
		calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.return_deck_after_losing_it_all()))
			
func _on_enemy_died(enemy: Enemy):
	current_enemies.erase(enemy)
	print('Current enemies on the field: ', current_enemies.size())
	var money_dropped = randi_range(5, 15)
	RunManager.add_currency(money_dropped)
	if current_enemies.size() == 0:
		calculator_ui.hide()
		print("Enemy Defeated!")
		var random_reward: Array[ItemData] = []
		for i in range(3):
			random_reward.append(LootManager.manage_loot(preload("res://resources/loot_table_world1.tres")).item)
		
		reward_screen.set_rewards(random_reward)
		var selection = await reward_screen.reward_selected
		RunManager.add_item_to_deck(selection)
		var route = await reward_screen.route_selected
		if route == 'shop':
			var shop_table = preload("res://resources/shop_loot_table_world1.tres")
			var shelf_items = LootManager.get_shop_items(shop_table, 3)
			shop_screen.open_shop(shelf_items)
			await shop_screen.next_battle
		elif route == 'battle':	
			calculator_ui.show()
			#SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
			spawn_new_enemy()
			calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))
			RunManager.current_hp = RunManager.max_hp
			calculator_ui._update_player_ui(RunManager.current_hp)

func _on_next_battle():
	calculator_ui.show()
		#SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
	spawn_new_enemy()
	calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))
	RunManager.current_hp = RunManager.max_hp
	calculator_ui._update_player_ui(RunManager.current_hp)	

func _on_reroll_selected(amount_rerolls: int, current_rewards: int, max_rewards: int):
	if(amount_rerolls == 1):
		var random_reward: Array[ItemData] = []
		for i in range(max_rewards + 1):
			random_reward.append(LootManager.manage_loot(preload("res://resources/loot_table_world1.tres")).item)
		reward_screen.set_rewards(random_reward, (max_rewards - current_rewards), true)
	else:
		pass

func _on_enemy_clicked(enemy: Enemy):
	if not clicked_targets.has(enemy):
		clicked_targets.append(enemy)
	else:
		return
	if clicked_targets.size() == number_of_targets:
		attack_execute()
	
func attack_execute():
	if RunManager.chaos_level >= 2 && (wait_payload.aoe_targets >= 2 || wait_payload.lifesteal_amount >=1 || wait_payload.hit_count >=2):
		RunManager.modifiy_hp(-5)
	while wait_payload.hit_count > 0:
		var are_you_alive: bool = false
		for target in clicked_targets:
			if not is_instance_valid(target):
				continue
			if target.current_hp <= 0:
				continue
			are_you_alive = true
			target.take_damage(wait_payload.base_damage)
			camera.apply_shake(5.0)
			SoundManager.play_sfx(preload("res://sfx/laserShoot (1).wav"))
		
		if are_you_alive == false:
			break
		wait_payload.hit_count -= 1
		await get_tree().create_timer(0.15).timeout
	if wait_payload.lifesteal_amount > 0:
		if RunManager.current_items.has(preload("res://resources/Items/PassiveItems/minus_monster.tres")):
			RunManager.modifiy_hp(wait_payload.lifesteal_amount * 2)
		else:	
			RunManager.modifiy_hp(wait_payload.lifesteal_amount)

func _on_item_added(passiveItem: PassiveItemData):
	if passiveItem.name == "Papaya":
		RunManager.max_hp += 5
		calculator_ui._update_player_ui(RunManager.max_hp)
	elif passiveItem.name == "Manzana":
		RunManager.max_hp += 10
		calculator_ui._update_player_ui(RunManager.max_hp)	
	elif passiveItem.name == "Uvas":
		RunManager.max_hp += 15
		calculator_ui._update_player_ui(RunManager.max_hp)	

func game_over():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	RunManager.start_new_run()

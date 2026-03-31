extends Node

@export var calculator_ui: Control
@export var spawn_point: Marker2D
@export var player_hp_label: Label
@export var reward_screen: Control
@export var enemy_scene: PackedScene
@export var encounter_type: Array[EncounterData]
@export var marker_array: Array[Marker2D]

@export var calculator_logic: Node

var number_of_targets: int = 0
var clicked_targets: Array[Node] = []

var wait_payload: AttackPayload

var current_enemies: Array = []

@export var max_player_hp: int = 100
var current_player_hp: int

var shake_strength: float = 0

var reward_pool = [
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_one.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/number_three.tres"),
	preload("res://resources/number_three.tres"),
	preload("res://resources/number_three.tres"),
	preload("res://resources/number_four.tres"),
	preload("res://resources/number_four.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/op_minus.tres"),
	preload("res://resources/op_minus.tres"),
	preload("res://resources/op_minus.tres"),
	preload("res://resources/op_minus.tres"),
	preload("res://resources/op_division.tres"),
	preload("res://resources/op_division.tres"),
	preload("res://resources/op_division.tres"),
	preload("res://resources/op_mult.tres"),
	preload("res://resources/op_mult.tres"),
]
func _ready() -> void:
	_update_player_ui(RunManager.current_hp)
	RunManager.hp_changed.connect(_update_player_ui)
	calculator_ui.attack_made.connect(_on_player_attack)
	calculator_ui.turn_ended.connect(_on_turn_ended)
	reward_screen.reroll_selected.connect(_on_reroll_selected)
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
	
func _update_player_ui(new_hp : int):
	player_hp_label.text = "PLAYER HP: " +  str(new_hp)

func take_damage(amount: int):
	RunManager.modifiy_hp(-amount)
	_update_player_ui(RunManager.current_hp)
	calculator_ui.apply_shake()
	SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
	
	if RunManager.current_hp <= 0:
		game_over()

func _on_turn_ended():
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			if enemy.current_hp > 0:
				enemy.state_machine.transition("Act")
	if(RunManager.deck.size() >= 1):
		calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))
		print("Shuffleando los shuffles")
	else:
		calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.return_deck_after_losing_it_all()))
			
func _on_enemy_died(enemy: Enemy):
	current_enemies.erase(enemy)
	print('Current enemies on the field: ', current_enemies.size())
	if current_enemies.size() == 0:
		calculator_ui.hide()
		print("Enemy Defeated!")
		var random_reward: Array[ItemData] = []
		for i in range(3):
			random_reward.append(reward_pool.pick_random())
		
		reward_screen.set_rewards(random_reward)
		var selection = await reward_screen.reward_selected
		print("Player chose: ", selection[0].display_name, selection[1].display_name)
		RunManager.add_item_to_deck(selection)
		calculator_ui.show()
		SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
		spawn_new_enemy()
		calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))
		RunManager.current_hp = RunManager.max_hp

func _on_reroll_selected(amountOfRerolls: int):
	if(amountOfRerolls == 1):
		var random_reward: Array[ItemData] = []
		for i in range(3):
			random_reward.append(reward_pool.pick_random())
		reward_screen.set_rewards(random_reward)
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
	while wait_payload.hit_count > 0:
		for target in clicked_targets:
			if not is_instance_valid(target):
				continue
			if target.current_hp <= 0:
				continue
			target.state_machine.transition("Act")
			target.take_damage(wait_payload.base_damage)
			calculator_ui.apply_shake()
			SoundManager.play_sfx(preload("res://sfx/laserShoot (1).wav"))
			wait_payload.hit_count -= 1
			await get_tree().create_timer(0.15).timeout
	if wait_payload.lifesteal_amount > 0:
			RunManager.modifiy_hp(wait_payload.lifesteal_amount)
	
func game_over():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	RunManager.start_new_run()

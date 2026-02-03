extends Node

@export var calculator_ui: Control
@export var spawn_point: Marker2D
@export var player_hp_label: Label
@export var reward_screen: Control
@export var enemy_scene: PackedScene

@export var calculator_logic: Node

var current_enemy: Enemy

@export var max_player_hp: int = 100
var current_player_hp: int

var shake_strength: float = 0

var reward_pool = [
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/op_plus.tres"),
	preload("res://resources/number_five.tres"),
	preload("res://resources/number_two.tres"),
	preload("res://resources/op_plus.tres")
]
	
func _input(event):
	if event.is_action_pressed("+1 Modifier"):
		apply_debug_upgrade()
	if event.is_action_pressed("*2 Modifier"):
		var hand_container = calculator_ui.get_node("HandContainer")
		var buttons = hand_container.get_children()
		if buttons.size() > 0:
			var first_button = buttons[0]
			first_button.data.add_modifier(preload("res://resources/mod_times_2.tres"))
			first_button.update_visuals()
	
func apply_debug_upgrade():
	print("Applying Upgrade")
	
	var mod = ModifierData.new()
	mod.type = ModifierData.Type.ADD_VALUE
	mod.value = 1
	
	var hand_container = calculator_ui.get_node("HandContainer")
	var buttons = hand_container.get_children()
	
	if buttons.size() > 0:
		var first_button = buttons[0]
		first_button.data.add_modifier(mod)
		first_button.update_visuals()
		
		print("Upgraded " + first_button.data.display_name)

func _ready() -> void:
	print("BattleManager ready")
	print("Enemy scene:", enemy_scene)
	print("Calculator UI:", calculator_ui)
	_update_player_ui(RunManager.current_hp)
	RunManager.hp_changed.connect(_update_player_ui)
	calculator_ui.attack_made.connect(_on_player_attack)
	calculator_ui.turn_ended.connect(_on_turn_ended)
	start_battle()
	

func start_battle():
	spawn_new_enemy()
	calculator_ui.start_turn(RunManager.deck)
	
func spawn_new_enemy():
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.position = spawn_point.position
	new_enemy.died.connect(_on_enemy_died)
	current_enemy = new_enemy

func _on_player_attack(damage: int):
	if is_instance_valid(current_enemy):
		current_enemy.take_damage(damage)
		RunManager.modifiy_hp(-current_enemy.attack())
		calculator_ui.apply_shake()
		SoundManager.play_sfx(preload("res://sfx/laserShoot (1).wav"))
	else:
		print("Enemy is already dead")
		
func _on_turn_ended():
	print("Turn Ended. Enemy Attacking...")
	
	if is_instance_valid(current_enemy):
		var damage = current_enemy.attack()
		RunManager.modifiy_hp(-damage)
			
		if RunManager.current_hp <= 0:
			game_over()
		
	await get_tree().create_timer(0.5).timeout
	
	calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))
	
func _update_player_ui(new_hp : int):
	player_hp_label.text = "PLAYER HP: " +  str(new_hp)

func take_damage(amount: int):
	current_player_hp -= amount
	_update_player_ui(current_player_hp)	
	calculator_ui.apply_shake()
	SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
	
	if current_player_hp <= 0:
		game_over()
		
func _on_enemy_died():
	calculator_ui.hide()
	print("Enemy Defeated!")
	var random_reward: Array[ItemData] = []
	for i in range(3):
		random_reward.append(reward_pool.pick_random())
	
	reward_screen.set_rewards(random_reward)
	var selection = await reward_screen.reward_selected
	print("Player chose: ", selection.display_name)
	RunManager.add_item_to_deck(selection)
	calculator_ui.show()
	SoundManager.play_sfx(preload("res://sfx/hitHurt.wav"))
	spawn_new_enemy()
	calculator_ui.draw_hand(RunManager.shuffle_deck(RunManager.deck))


func game_over():
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

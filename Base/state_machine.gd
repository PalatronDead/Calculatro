class_name StateMachine extends Node

@export var is_log_enabled: bool = false

var current_state: State
var states: Dictionary = {}
var _parent_node_name: String

func start_machine(init_states: Array[State]) -> void:
	_parent_node_name = get_parent().name
	for state in init_states:
		states[state.get_state_name()] = state 
		
	current_state = init_states[0]
	current_state.enter()
	
	if is_log_enabled:
		print('[%s]: Entering State\"%s\"' % [_parent_node_name, current_state.get_state_name()])

func _process(delta: float) -> void:
	current_state.process(delta)
	
func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)

func transition(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name)
	var current_state_name = current_state.get_state_name()
	
	if new_state == null:
		push_error("An attempt has been made to transition to a non existent state (%s)" % new_state_name)
	elif new_state != current_state:
		current_state.exit()
		
				
		if is_log_enabled:
			print('[%s]: Entering State\"%s\"' % [_parent_node_name, current_state.get_state_name()])
		
		current_state = states[new_state.get_state_name()]
		
		if is_log_enabled:
			print('[%s]: Entering State\"%s\"' % [_parent_node_name, current_state.get_state_name()])
		
		current_state.enter()

	else:
		push_warning("An attempt to transision to the current state has been made. Ignoring request.")

class_name CommandQueue extends Node

signal command_started(cmd: Command)
signal command_finished(cmd: Command)

var queue: Array[Command] = []
var is_processing: bool = false

func add(cmd: Command):
	queue.append(cmd)
	if not is_processing:
		process_next()
	
func process_next():
	is_processing = true
	
	while not queue.is_empty():
		
		var current_cmd = queue.pop_front()
	
		command_started.emit(current_cmd)
	
		await current_cmd.execute()
	
		command_finished.emit(current_cmd)
	
	is_processing = false

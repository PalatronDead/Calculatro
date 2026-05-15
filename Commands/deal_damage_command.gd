class_name DealDamageCommand extends Command

var base_damage: int
var final_damage: int
var target: Node
var source: Node

func _init(_damage: int, _target: Node, _source: Node):
	base_damage = _damage
	final_damage = _damage 
	target = _target
	source = _source

func execute():
	if not is_instance_valid(target) or target.current_hp <= 0:
			return
	RunManager.emit_signal("on_damage_calculating", self)
	target.take_damage(final_damage)
	
	source.camera.apply_shake(5.0)
	SoundManager.play_sfx(preload("res://sfx/laserShoot (1).wav"))

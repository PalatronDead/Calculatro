extends Node


func manage_loot(loot_table: LootTable) -> LootItem:
	var total_weight: int = 0
	for loot_item in loot_table.loot_items:
		total_weight += loot_item.loot_weight
	var loot_number = randi_range(1, total_weight)
	for loot_item in loot_table.loot_items:
		loot_number -= loot_item.loot_weight
		if(loot_number <= 0):
			return loot_item
	return

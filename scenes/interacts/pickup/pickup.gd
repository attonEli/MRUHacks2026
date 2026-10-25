extends Interactable

@export_enum("key_x", "key_y", "key_z", "key_master", "key_cabinet", "manual", "morse_sheet", "map")
var item_id: String = "key_x"


func get_display_name() -> String:
	if display_name != "":
		return display_name
	return GameState.ITEM_NAMES.get(item_id, item_id)


func interact() -> void:
	GameState.add_item(item_id)
	GameState.show_message("You picked up the %s." % GameState.ITEM_NAMES.get(item_id, item_id))
	queue_free()

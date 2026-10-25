extends "res://scenes/interacts/pickup/readable.gd"
## Office file cabinet. Locked until the player has the cabinet key (required_item).
## The first time it opens it gives everything inside (the Morse sheet and the
## master key for switch 4), then it shows the Morse sheet every time it's used.

@export var items_inside: Array[String] = ["morse_sheet", "key_master"]
@export var unlock_message := "The cabinet key turns. Inside are a Morse code sheet and a heavy master key."

var _opened := false


func interact() -> void:
	if not _opened:
		_opened = true
		for item_id in items_inside:
			GameState.add_item(item_id)
		GameState.show_message(unlock_message)
	super()

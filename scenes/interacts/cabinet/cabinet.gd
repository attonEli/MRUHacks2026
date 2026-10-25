extends "res://scenes/interacts/pickup/readable.gd"
## Office file cabinet. Locked until the player has the cabinet key (required_item),
## then it gives the Morse sheet and shows it every time it's used.

@export var unlock_message := "The cabinet key turns. Inside is a Morse code sheet."

var _opened := false


func interact() -> void:
	if not _opened:
		_opened = true
		GameState.add_item(GameState.MORSE_SHEET)
		GameState.show_message(unlock_message)
	super()

extends Interactable
## Something the player reads in place (notes, manual, signs). Stays in the world.
## If item_id is set, reading it also adds it to the inventory, where it can be read again.

@export var title := "Note"
@export_multiline var body := ""
@export var item_id := "" ## e.g. "manual", "map", "morse_sheet". Empty = not collectable.


func _ready() -> void:
	super()
	if item_id != "":
		GameState.register_document(item_id, title, body)


func interact() -> void:
	if item_id != "" and not GameState.has_item(item_id):
		GameState.add_item(item_id)
		GameState.show_message("%s added to your inventory." % GameState.ITEM_NAMES.get(item_id, item_id))
	GameState.show_document(title, body)

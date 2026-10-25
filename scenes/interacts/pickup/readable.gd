extends Interactable
## Something the player reads in place (notes, manual, signs). Stays in the world.

@export var title := "Note"
@export_multiline var body := ""


func interact() -> void:
	GameState.show_document(title, body)

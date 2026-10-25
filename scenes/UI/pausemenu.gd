extends CanvasLayer

signal resume_pressed(origin: String)
signal quit_to_main_pressed(origin: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quittomain_pressed() -> void:
	quit_to_main_pressed.emit("quit_to_menu")


func _on_resume_pressed() -> void:
	resume_pressed.emit("unpause")

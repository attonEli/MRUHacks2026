extends Control

signal start_pressed(origin: String)
signal options_pressed(origin: String)
signal quit_pressed(origin: String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_pressed() -> void:
	start_pressed.emit("main_menu")


func _on_options_pressed() -> void:
	options_pressed.emit("main_menu")


func _on_start_pressed() -> void:
	quit_pressed.emit("main_menu")

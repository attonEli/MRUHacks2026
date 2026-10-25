extends PanelContainer
## Telegraph minigame, opened by GameState.telegraph_opened.
## Tap SPACE for a dot, hold it for a dash, BACKSPACE to undo, ENTER to send.
## Lives inside the Hud autoload, so it keeps running while the game is paused.

const DASH_MS := 250 ## Holding SPACE longer than this makes a dash

@onready var tape_label: Label = %TapeLabel
@onready var leave_button: Button = %LeaveButton

var _symbols := ""
var _press_started_ms := 0


func _ready() -> void:
	hide()
	leave_button.pressed.connect(_close)
	GameState.telegraph_opened.connect(_open)


func _open() -> void:
	_symbols = ""
	_press_started_ms = 0
	_update_tape()
	show()
	get_tree().paused = true


func _close() -> void:
	hide()
	get_tree().paused = false


# _input runs before the buttons see the key, so SPACE never "clicks" Leave.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	var key := event as InputEventKey
	if key == null or key.echo:
		return
	get_viewport().set_input_as_handled()

	if key.keycode == KEY_SPACE:
		if key.pressed:
			_press_started_ms = Time.get_ticks_msec()
		elif _press_started_ms > 0:
			var held := Time.get_ticks_msec() - _press_started_ms
			_symbols += "-" if held > DASH_MS else "."
			_press_started_ms = 0
			_update_tape()
	elif key.pressed:
		match key.keycode:
			KEY_BACKSPACE:
				_symbols = _symbols.left(-1)
				_update_tape()
			KEY_ENTER, KEY_KP_ENTER:
				_send()
			KEY_ESCAPE:
				_close()


func _send() -> void:
	if _symbols == "":
		return
	var symbols := _symbols
	_symbols = ""
	_update_tape()
	if GameState.send_telegraph(symbols):
		hide() # The ending screen takes over, so the game stays paused.


func _update_tape() -> void:
	if _symbols == "":
		tape_label.text = "_"
	else:
		tape_label.text = _symbols.replace(".", "• ").replace("-", "— ")

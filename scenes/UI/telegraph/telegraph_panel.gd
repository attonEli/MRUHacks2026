extends PanelContainer
## Telegraph minigame, opened by GameState.telegraph_opened.
## Tap SPACE for a dot, hold it for a dash, BACKSPACE to undo, ENTER to send.
## Pausing ends the letter (a " " gap), pausing longer starts a new word ("/").
## Lives inside the Hud autoload, so it keeps running while the game is paused.

const DASH_MS := 250 ## Holding SPACE longer than this makes a dash
const LETTER_GAP_MS := 800 ## A pause this long after a dot/dash ends the letter
const WORD_GAP_MS := 2000 ## A pause this long starts a new word

@onready var tape_label: Label = %TapeLabel
@onready var decoded_label: Label = %DecodedLabel
@onready var leave_button: Button = %LeaveButton
@onready var morse_sheet: Control = %MorseSheet
@onready var morse_grid: GridContainer = %MorseGrid

var _symbols := ""
var _press_started_ms := 0
var _last_release_ms := 0


func _ready() -> void:
	hide()
	leave_button.pressed.connect(_close)
	GameState.telegraph_opened.connect(_open)
	_build_morse_sheet()


func _open() -> void:
	_symbols = ""
	_press_started_ms = 0
	_update_tape()
	morse_sheet.visible = GameState.has_item(GameState.MORSE_SHEET) # Only once it's been found
	show()
	get_tree().paused = true


func _close() -> void:
	hide()
	get_tree().paused = false


func _process(_delta: float) -> void:
	if not visible or _symbols == "" or _press_started_ms > 0:
		return
	var paused_ms := Time.get_ticks_msec() - _last_release_ms
	if _symbols.ends_with(" "):
		if paused_ms > WORD_GAP_MS:
			_symbols = _symbols.left(-1) + "/"
			_update_tape()
	elif not _symbols.ends_with("/") and paused_ms > LETTER_GAP_MS:
		_symbols += " "
		_update_tape()


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
			_last_release_ms = Time.get_ticks_msec()
			_update_tape()
	elif key.pressed:
		match key.keycode:
			KEY_BACKSPACE:
				_undo()
			KEY_ENTER, KEY_KP_ENTER:
				_send()
			KEY_ESCAPE:
				_close()


## Removes the last dot/dash (and any gap after it), so the player can keep typing that letter.
func _undo() -> void:
	_symbols = _symbols.rstrip(" /").left(-1)
	_last_release_ms = Time.get_ticks_msec()
	_update_tape()


func _send() -> void:
	var symbols := _symbols.strip_edges().rstrip(" /")
	if symbols == "":
		return
	_symbols = ""
	_update_tape()
	GameState.send_telegraph(symbols)
	hide() # The ending screen takes over, so the game stays paused.


func _update_tape() -> void:
	if _symbols == "":
		tape_label.text = "_"
		decoded_label.text = ""
	else:
		tape_label.text = GameState.pretty_morse(_symbols)
		decoded_label.text = GameState.decode_morse(_symbols)


## One small label per letter, filled in from GameState.MORSE.
func _build_morse_sheet() -> void:
	for letter in GameState.MORSE:
		var entry := Label.new()
		entry.text = "%s   %s" % [letter, GameState.pretty_morse(GameState.MORSE[letter])]
		entry.add_theme_font_size_override("font_size", 17)
		entry.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75, 1))
		morse_grid.add_child(entry)

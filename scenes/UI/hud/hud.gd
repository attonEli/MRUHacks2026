extends CanvasLayer
## On-screen HUD for the breaker puzzle.
## - MessagePanel: shows every GameState.show_message() text for a few seconds.
## - CountdownLabel: shows the switch countdown, then the cooldown after a failure.
## - KeyPicker: opens when a locked switch is used, so the player picks a key.
## - DocumentPanel: shows notes/manuals, and the ending text when the game is won.
## - TelegraphPanel: the Morse minigame (its own script, telegraph_panel.gd).
## - InventoryPanel: toggled with I, lists the items the player is carrying.
## Runs as an autoload (process_mode = Always) so it keeps working while the game
## is paused for the key picker.

const MESSAGE_SECONDS := 3.0
const COUNTDOWN_WARNING_SECONDS := 5.0

const COLOR_NORMAL := Color(1.0, 0.85, 0.5)
const COLOR_WARNING := Color(1.0, 0.3, 0.25)
const COLOR_COOLDOWN := Color(0.6, 0.6, 0.6)

@onready var countdown_label: Label = %CountdownLabel
@onready var message_panel: PanelContainer = %MessagePanel
@onready var message_label: Label = %MessageLabel
@onready var message_timer: Timer = %MessageTimer
@onready var key_picker: PanelContainer = %KeyPicker
@onready var picker_title: Label = %PickerTitle
@onready var key_list: VBoxContainer = %KeyList
@onready var cancel_button: Button = %CancelButton
@onready var document_panel: PanelContainer = %DocumentPanel
@onready var doc_title: Label = %DocTitle
@onready var doc_body: Label = %DocBody
@onready var doc_close_button: Button = %DocCloseButton
@onready var inventory_panel: PanelContainer = %InventoryPanel
@onready var inventory_list: VBoxContainer = %InventoryList

var _pending_switch := 0
var _game_finished := false


func _ready() -> void:
	countdown_label.hide()
	message_panel.hide()
	key_picker.hide()
	document_panel.hide()
	inventory_panel.hide()

	message_timer.wait_time = MESSAGE_SECONDS
	message_timer.timeout.connect(message_panel.hide)
	cancel_button.pressed.connect(_close_key_picker)
	doc_close_button.pressed.connect(_close_document)

	GameState.message_shown.connect(_on_message_shown)
	GameState.key_choice_needed.connect(_on_key_choice_needed)
	GameState.document_shown.connect(_on_document_shown)
	GameState.game_over.connect(_on_game_over)
	GameState.item_added.connect(_refresh_inventory.unbind(1))
	GameState.item_removed.connect(_refresh_inventory.unbind(1))


func _process(_delta: float) -> void:
	_update_countdown()


# --- Countdown / cooldown clock -------------------------------------------

func _update_countdown() -> void:
	var time_left := GameState.get_countdown_left()
	if time_left > 0.0:
		countdown_label.text = "TIMER: %.1f s" % time_left
		if time_left <= COUNTDOWN_WARNING_SECONDS:
			countdown_label.modulate = COLOR_WARNING
		else:
			countdown_label.modulate = COLOR_NORMAL
		countdown_label.show()
	elif GameState.is_in_cooldown():
		countdown_label.text = "RECHARGING: %d s" % ceili(GameState.cooldown_timer.time_left)
		countdown_label.modulate = COLOR_COOLDOWN
		countdown_label.show()
	else:
		countdown_label.hide()


# --- Message box -----------------------------------------------------------

func _on_message_shown(text: String) -> void:
	message_label.text = text
	message_panel.show()
	message_timer.start()


# --- Key picker ------------------------------------------------------------

func _on_key_choice_needed(switch_number: int) -> void:
	_pending_switch = switch_number
	picker_title.text = "Switch %d is locked.\nWhich key do you use?" % switch_number

	for child in key_list.get_children():
		key_list.remove_child(child)
		child.queue_free()

	var first_button: Button = null
	for key_id in GameState.get_held_keys():
		var button := Button.new()
		button.text = GameState.ITEM_NAMES.get(key_id, key_id)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_key_picked.bind(key_id))
		key_list.add_child(button)
		if first_button == null:
			first_button = button

	key_picker.show()
	get_tree().paused = true
	if first_button:
		first_button.grab_focus()


func _on_key_picked(key_id: String) -> void:
	var switch_number := _pending_switch
	_close_key_picker()
	GameState.try_unlock_switch(switch_number, key_id)


func _close_key_picker() -> void:
	key_picker.hide()
	_pending_switch = 0
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if key_picker.visible and event.is_action_pressed("ui_cancel"):
		_close_key_picker()
		get_viewport().set_input_as_handled()
	elif document_panel.visible and event.is_action_pressed("ui_cancel"):
		_close_document()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("inventory"):
		_toggle_inventory()
		get_viewport().set_input_as_handled()


# --- Inventory -------------------------------------------------------------

func _toggle_inventory() -> void:
	inventory_panel.visible = not inventory_panel.visible
	_refresh_inventory()


func _refresh_inventory() -> void:
	for child in inventory_list.get_children():
		inventory_list.remove_child(child)
		child.queue_free()

	if GameState.inventory.is_empty():
		_add_inventory_line("Nothing yet.", Color(0.6, 0.6, 0.55))
		return
	for item_id in GameState.inventory:
		var item_name: String = GameState.ITEM_NAMES.get(item_id, item_id)
		if GameState.can_read(item_id):
			_add_readable_line(item_name, item_id)
		else:
			_add_inventory_line("• " + item_name, Color(0.9, 0.9, 0.85))


## Readable items are buttons: click to open the document again.
func _add_readable_line(item_name: String, item_id: String) -> void:
	var button := Button.new()
	button.text = "• %s  [Read]" % item_name
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.focus_mode = Control.FOCUS_NONE # So WASD / Space still go to the player
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(1.0, 0.85, 0.5))
	button.pressed.connect(GameState.read_item.bind(item_id))
	inventory_list.add_child(button)


func _add_inventory_line(text: String, color: Color) -> void:
	var line := Label.new()
	line.text = text
	line.add_theme_font_size_override("font_size", 20)
	line.add_theme_color_override("font_color", color)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_list.add_child(line)


# --- Document popup / ending -----------------------------------------------

func _on_document_shown(title: String, body: String) -> void:
	doc_title.text = title
	doc_body.text = body
	document_panel.show()
	get_tree().paused = true
	doc_close_button.grab_focus()


func _close_document() -> void:
	if _game_finished:
		get_tree().quit()
		return
	document_panel.hide()
	get_tree().paused = false


func _on_game_over(ending: String) -> void:
	_game_finished = true
	var text: String
	if ending == "rescue":
		text = "%s\n\n%s" % [
			GameState.decode_morse(GameState.telegraph_message),
			GameState.pretty_morse(GameState.telegraph_message),
		]
	else:
		text = GameState.ENDINGS[ending]
	_on_document_shown("THE END", text)
	doc_close_button.text = "Quit"

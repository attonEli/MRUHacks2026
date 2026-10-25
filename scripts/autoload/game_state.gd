extends Node

const KEY_X := "key_x" #switch 2
const KEY_Y := "key_y" #switch 3
const KEY_Z := "key_z" #switch 1
const KEY_MASTER := "key_master" # Switch 4
const KEY_CABINET := "key_cabinet" #Key for the cabinet in the office
const MANUAL := "manual" # The manual in the libary
const MORSE_SHEET := "morse_sheet" # Morse code sheet in the office file cabinet
const MAP := "map" # Map room

signal item_added(item_id: String)
signal switch_changed(switch_number: int, is_on: bool)
signal message_shown(text: String)

signal countdown_started(seconds: float)
signal puzzle_failed(reason: String)
signal cooldown_finished
signal power_restored

const COUNTDOWN_SECONDS := 15.0
const COOLDOWN_SECONDS := 5.0 

const ITEM_NAMES := {
	KEY_X: "key_x",
	KEY_Y: "key_y",
	KEY_Z: "key_z",
	KEY_MASTER: "key_master",
}

const SWITCH_KEYS := {
	1: KEY_Z,
	2: KEY_X,
	3: KEY_Y,
	4: KEY_MASTER,
}

signal item_removed(item_id: String)
signal switch_unlocked(switch_number: int)
signal key_choice_needed(switch_number: int)

var switches_unlocked := {1: false, 2: false, 3: false, 4: false}

var inventory: Array[String] = []

var switches_on := {1: false, 2: false, 3: false, 4: false}
var correct_order: Array[int] = [2, 1, 3, 4]

var is_powered := false
var countdown_timer : Timer
var cooldown_timer: Timer

var _debug_pending_switch := 0

var order_progress := 0

func has_item(item_id: String) -> bool:
	return item_id in inventory

func add_item(item_id: String) -> void:
	if has_item(item_id):
		return
	inventory.append(item_id)
	item_added.emit(item_id)

func show_message(text: String) -> void:
	print("[MSG] ", text)
	message_shown.emit(text)
	
func _ready() -> void:
	print("[DEBUG] Switch order: ", correct_order)
	countdown_timer = _make_timer("CountdownTimer", _on_countdown_timeout)
	cooldown_timer = _make_timer("CooldownTimer", _on_cooldown_timeout)
	if OS.is_debug_build():
		key_choice_needed.connect(_debug_on_key_choice_needed)
	
func _make_timer(timer_name: String, on_timeout: Callable) -> Timer:
	var timer := Timer.new()
	timer.name = timer_name
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_timeout)
	return timer

func _on_countdown_timeout() -> void:
	_fail("timeout")


func _on_cooldown_timeout() -> void:
	cooldown_finished.emit()
	show_message("The breakers click. You can try again.")
	
func try_flip_switch(number: int) -> bool:
	if is_powered:
		show_message("The power is already on.")
		return false
	if is_in_cooldown():
		show_message("The breaker is still recharging...")
		return false
	if switches_on[number]:
		show_message("This switch is already on.")
		return false
	if not switches_unlocked[number]:
		show_message("The switch is locked.")
		return false

	if number != correct_order[order_progress]:
		_fail("wrong_order")
		return false
	
	switches_on[number] = true
	switch_changed.emit(number, true)
	order_progress += 1
	
	if order_progress == 1:
		countdown_timer.start(COUNTDOWN_SECONDS)
		countdown_started.emit(COUNTDOWN_SECONDS)
	if order_progress == correct_order.size():
		countdown_timer.stop()
		is_powered = true
		power_restored.emit()
		show_message("The network is up!")
		
	return true
	
func _fail(reason: String) -> void:
	for number in switches_on:
		if switches_on[number]:
			switches_on[number] = false
			switch_changed.emit(number, false)
	order_progress = 0
	countdown_timer.stop()
	cooldown_timer.start(COOLDOWN_SECONDS)
	puzzle_failed.emit(reason)
	
	if reason == "timeout":
		show_message("The power fails. Every switch snaps off")
	else:
		show_message("Wrong switch order. Everything shuts off!")
		
func is_in_cooldown() -> bool:
	return not cooldown_timer.is_stopped()

func get_countdown_left() -> float:
	if countdown_timer.is_stopped():
		return 0.0
	return countdown_timer.time_left
	
func use_switch(number: int) -> void:
	if switches_unlocked[number]:
		try_flip_switch(number)
		return
	if get_held_keys().is_empty():
		show_message("The switch is locked. It needs a key.")
		return
	key_choice_needed.emit(number)


func get_held_keys() -> Array[String]:
	var keys: Array[String] = []
	for item in inventory:
		if item in SWITCH_KEYS.values():
			keys.append(item)
	return keys


func try_unlock_switch(number: int, key_id: String) -> bool:
	if not has_item(key_id):
		return false
	if SWITCH_KEYS[number] != key_id:
		show_message("The %s doesn't fit." % ITEM_NAMES[key_id])
		return false

	switches_unlocked[number] = true
	inventory.erase(key_id)
	item_removed.emit(key_id)
	switch_unlocked.emit(number)
	show_message("The %s turns. The switch is unlocked." % ITEM_NAMES[key_id])
	return true

func _debug_on_key_choice_needed(number: int) -> void:
	_debug_pending_switch = number
	print("[DEBUG] Switch %d is locked. Pick with 7/8/9/0: %s" % [number, get_held_keys()])


func _debug_pick_key(index: int) -> void:
	var keys := get_held_keys()
	if _debug_pending_switch == 0 or index >= keys.size():
		return
	try_unlock_switch(_debug_pending_switch, keys[index])
	_debug_pending_switch = 0


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_1: use_switch(1)
		KEY_2: use_switch(2)
		KEY_3: use_switch(3)
		KEY_4: use_switch(4)
		KEY_7: _debug_pick_key(0)
		KEY_8: _debug_pick_key(1)
		KEY_9: _debug_pick_key(2)
		KEY_0: _debug_pick_key(3)
		KEY_K: _debug_give_all_items()
		KEY_T: print("[DEBUG] Time left: ", get_countdown_left())


func _debug_give_all_items() -> void:
	for item in [KEY_X, KEY_Y, KEY_Z, KEY_MASTER, KEY_CABINET, MANUAL, MORSE_SHEET, MAP]:
		add_item(item)
	print("[DEBUG] Gave all items: ", inventory)

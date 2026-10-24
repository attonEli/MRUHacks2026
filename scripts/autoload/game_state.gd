extends Node

const KEY_SWITCHES := "key_switches" # Switches 1-3
const KEY_MASTER := "key_master" # Switch 4
const KEY_CABINET := "key_cabinet" #Key for the cabinet in the office
const MANUAL := "manual" # The manual in the libary
const MORSE_SHEET := "morse_sheet" # Morse code sheet in the office file cabinet
const MAP := "map" # Map room

signal item_added(item_id: String)
signal switched_changed(switch_number: int, is_on: bool)
signal message_shown(text: String)

var inventory: Array[String] = []

var switches_on := {1: false, 2: false, 3: false, 4: false}
var correct_order: Array[int] = [2, 1, 3, 4]
var order_progress := 0

func has_item(item_id: String) -> bool:
	return item_id in inventory

func add_item(item_id: String) -> void:
	if has_item(item_id):
		return
	inventory.append(item_id)
	item_added.emit(item_id)

func show_message(text: String) -> void:
	message_shown.emit(text)

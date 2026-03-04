extends Node2D

#region Initiation

## Banks Settings 
var bank_list: Dictionary
var master_strings_bank: FmodBank
var master_bank: FmodBank

const MASTER_STRINGS_BANK: String = "res://audio/banks/Desktop/Master.strings.bank"
const MASTER_BANK: String = "res://audio/banks/Desktop/Master.bank"

var master_bus: FmodBus
var ambient_bus: FmodBus
var music_bus: FmodBus
var sfx_bus: FmodBus

func load_banks() -> void:
	bank_list["master_strings_bank"] = FmodServer.load_bank(MASTER_STRINGS_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	bank_list["master_bank"] = FmodServer.load_bank(MASTER_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)

func load_emitters() -> void:
	for emitter in get_children():
		if emitter is FmodEventEmitter2D:
			emitter_list.append(emitter)

func _ready() -> void:
	load_banks()
	load_emitters()

#endregion

#region Playback

## Mixer Settings
@export_range(0.0, 100.0, 1.0) var master_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var ambient_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var music_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var sfx_volume: float = 100.0

## Playback Settings
var emitter_list: Array
const PLAYING = FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING
const STOPPED = FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED

## Parameter Settings
var muffled: bool = false

const MUFFLE: String = "Muffle"
const TRUE: String = "true"
const FALSE: String = "false"

func play(
caller: Node,
sound_path: String, 
object_transform: Transform2D = global_transform, 
parameter: String = "", 
value: Variant = null
):

	#TODO: Create ID
	if(sound_path == ""):
		if caller.get_parent():
			push_error("no valid audio path from " + caller.get_parent().name)
			return
		else: push_error("no valid audio path from: " + caller.name)

	if not FmodServer.check_event_path(sound_path):
		push_error("invalid FMOD event path: " + sound_path + " FROM " + caller.name)
		return

	var instance: FmodEvent
	if sound_path.contains('{'):
		print("finding guid")
		instance = FmodServer.create_event_instance_with_guid(sound_path)

	else: instance = FmodServer.create_event_instance(sound_path)

	instance.set_2d_attributes(object_transform)

	if value is float or value is int: instance.set_parameter_by_name(parameter, value)
	if value is String: instance.set_parameter_by_name_with_label(parameter, value, false)

	instance.start()
	instance.release()

func play_instance(
	caller: Node, 
	sound_path: String, 
	object_transform: Transform2D = global_transform
	) -> FmodEvent:

	if(sound_path == ""):
		if caller.get_parent():
			push_error("no valid audio path from " + caller.get_parent().name)
			return
		else: push_error("no valid audio path from: " + caller.name)

	if not FmodServer.check_event_path(sound_path):
		push_error("invalid FMOD event path: " + sound_path + " FROM " + caller.name)
		return

	var instance: FmodEvent = FmodServer.create_event_instance(sound_path)
	instance.set_2d_attributes(object_transform)
	instance.start()
	return instance

func clear_instance(instances: Array[FmodEvent], timer: float = 0) -> void:
	if timer != 0: await get_tree().create_timer(timer).timeout
	for instance in instances:
		if instance == null: return
		instance.stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		instance.release()

func muffle(state: bool = false) -> void: 
	if state:
		FmodServer.set_global_parameter_by_name_with_label(MUFFLE, TRUE)
		muffled = true
	else:
		FmodServer.set_global_parameter_by_name_with_label(MUFFLE, FALSE)
		muffled = false

#endregion

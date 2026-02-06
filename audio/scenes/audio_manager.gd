extends Node2D

## -- Banks Settings -- 
var bank_list: Dictionary
var master_strings_bank: FmodBank
var master_bank: FmodBank

const MASTER_STRINGS_BANK: String = "res://audio/banks/Desktop/Master.strings.bank"
const MASTER_BANK: String = "res://audio/banks/Desktop/Master.bank"

## -- Mixer Settings --
@export_range(0.0, 100.0, 1.0) var master_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var ambient_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var music_volume: float = 100.0
@export_range(0.0, 100.0, 1.0) var sfx_volume: float = 100.0

var master_bus: FmodBus
var ambient_bus: FmodBus
var music_bus: FmodBus
var sfx_bus: FmodBus

## -- Playback Settings --
var emitter_list: Array
const PLAYING = FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING
const STOPPED = FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED

## -- Parameter Settings --
var muffled: bool = false

const MUFFLE: String = "Muffle"
const TRUE: String = "true"
const FALSE: String = "false"

func _ready() -> void:
	load_banks()
	load_emitters()

func load_banks() -> void:
	bank_list["master_strings_bank"] = FmodServer.load_bank(MASTER_STRINGS_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	bank_list["master_bank"] = FmodServer.load_bank(MASTER_BANK, FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)

func load_emitters() -> void:
	for emitter in get_children():
		if emitter is FmodEventEmitter2D:
			emitter_list.append(emitter)

func play(
sound_path: String, 
object_transform: Transform2D = global_transform, 
parameter: String = "", 
value: Variant = null
):

	if(sound_path == null): return

	var instance: FmodEvent = FmodServer.create_event_instance(sound_path)
	instance.set_3d_attributes(object_transform)

	if value is float: instance.set_parameter_by_name(parameter, value)
	if value is String: instance.set_parameter_by_name_with_label(parameter, value, false)
	else: pass

	instance.start()
	instance.release()

func play_id(sound_id: String) -> void: FmodServer.play_one_shot_using_guid(sound_id)

func play_instance(sound_path: String, object_transform: Transform2D) -> FmodEvent:
	if sound_path == null: push_error("audio missing")

	var instance: FmodEvent = FmodServer.create_event_instance(sound_path)
	instance.set_3d_attributes(object_transform)
	instance.start()
	return instance

func clear_instance(instances: Array[FmodEvent]) -> void:
	if instances == null: return

	for instance in instances:
		instance.stop(FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT)
		instance.release()

func clear_emitter(instances: Array[FmodEventEmitter2D]) -> void:
	if instances == null: return

	for emitter in instances:
		emitter.stop()
		emitter.release()

func muffle(force: bool = false, state: bool = false) -> void: 
	if force and state:
		FmodServer.set_global_parameter_by_name_with_label(MUFFLE, TRUE)
		muffled = true
	if force and !state:
		FmodServer.set_global_parameter_by_name_with_label(MUFFLE, FALSE)
		muffled = false

	if !muffled: 
		FmodServer.set_global_parameter_by_name_with_label(MUFFLE, TRUE)
		muffled = true
	else:
		FmodServer.set_global_parameter_by_name_with_label(MUFFLE, FALSE)
		muffled = false

func free() -> void: clear_emitter(emitter_list)

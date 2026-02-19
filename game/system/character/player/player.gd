class_name Player extends Character

var selected_target: Anatomy

@onready var retro_screen: RetroScreen = %RetroScreen
var retro_mat: ShaderMaterial

var health_tween: Tween

var player_health_effect_value := 30.0:
	set(value):
		player_health_effect_value = value
		if health_tween: health_tween.kill()
		health_tween = create_tween()
		health_tween.tween_property(
			retro_mat, 
			"shader_parameter/color_quant_steps", 
			value, 
			0.4
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

var first_level := true

@onready var eye_l: Anatomy = %EyeL
@onready var nose: Anatomy = %Nose
@onready var ear_l: Anatomy = %EarL
@onready var ear_r: Anatomy = %EarR

func _ready() -> void:
	retro_mat = retro_screen.material as ShaderMaterial

func get_anatomy_references() -> void:
	super.get_anatomy_references()
	for a in anatomy_parts:
		if not a.anatomy_clicked.is_connected(_on_self_anatomy_clicked):
			a.anatomy_clicked.connect(_on_self_anatomy_clicked)
	for a in opponent_anatomy:
		if not a.anatomy_clicked.is_connected(_on_enemy_anatomy_clicked):
			a.anatomy_clicked.connect(_on_enemy_anatomy_clicked)

func start_round() -> void:
	super.start_round()
	if selected_target:
		if selected_target in opponent_anatomy:
			selected_target.is_targeted = true
			selected_target._highlight_target()

func end_battle() -> void:
	super.end_battle()
	if selected_target:
		selected_target.is_targeted = false
		selected_target._unhighlight_target()
		selected_target = null

#func choose_target() -> Anatomy:
	#if selected_target and selected_target.state != Anatomy.PartState.DESTROYED:
		#return selected_target
	#return null

func set_hp(amount: float) -> void:
	super.set_hp(amount)
	Tutorial.self_broken_part()

var locking_on_target := false

func _on_attack_finished() -> void:
	super._on_attack_finished()
	if selected_target == null:
		return
	if not locking_on_target:
		selected_target.is_targeted = false
		selected_target._unhighlight_target()
		selected_target = null

func _on_action_ready() -> void:
	if not can_control:
		selected_target.is_targeted = false
		selected_target._unhighlight_target()
		return
	super._on_action_ready()
	if selected_target and can_action and not blocking_part:
		if selected_target.state != Anatomy.PartState.DESTROYED:
			_perform_attack(selected_target)
		else:
			selected_target.is_targeted = false
			selected_target._unhighlight_target()
			selected_target = null
			arm.rest_pos()


func _on_successful_block(attacker: Character) -> void:
	super._on_successful_block(attacker)
	Tutorial.on_block_success()

func _on_block_finished() -> void:
	super._on_block_finished()
	if selected_target:
		selected_target._unhighlight_target()
	selected_target = null
	if blocking_part:
		blocking_part.is_blocking = false
	blocking_part = null
	arm.interrupt(func(): 
		if can_control:
			pass
			#combat_component.reset_attack_timer(action_cooldown)
			#combat_component.start()
	)

func get_ready_to_battle() -> void:
	super.get_ready_to_battle()
	for part: Anatomy in features.get_children():
		if not part.body_owner or part.body_owner != self:
			part.reparent(Stats.rest_room.background)
	
	if first_level:
		first_level = false
		#if eye_l: eye_l.set_hp(1)
		#if ear_r: ear_l.set_hp(1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		if selected_target and selected_target.lock.visible:
			selected_target.lock.visible = false
		locking_on_target = false
		if arm.is_punching:
			return
		arm.rest_pos()
		if selected_target:
			if selected_target in anatomy_parts:
				selected_target.is_blocking = false
				if blocking_part:
					blocking_part.is_blocking = false
				blocking_part = null
			elif not can_action:
				selected_target.is_targeted = false
				selected_target._unhighlight_target()
			selected_target = null


func _on_self_anatomy_clicked(anatomy: Anatomy) -> void:
	if (arm.movable_by_mouse and anatomy.state == Anatomy.PartState.FUCKED) or (rest_mode): #and anatomy.state != Anatomy.PartState.HEALTHY
		arm.pickup_obj(anatomy)
		arm.z_index = -2
		return

	if arm.is_punching or not can_control:
		return
	
	Tutorial.on_first_block()
	locking_on_target = false
	if selected_target and selected_target.lock.visible:
		selected_target.lock.visible = false
		
		
	if selected_target != anatomy:
		if selected_target:
			if selected_target in opponent_anatomy:
				selected_target.is_targeted = false
				selected_target._unhighlight_target()
		selected_target = anatomy
		_perform_block(anatomy)
	else:
		selected_target = null
		if blocking_part:
			blocking_part.is_blocking = false
		blocking_part = null
		anatomy._unhighlight_target()
		arm.rest_pos()

var animating_target := false

func _on_enemy_anatomy_clicked(anatomy: Anatomy) -> void:
	if anatomy.state == Anatomy.PartState.DESTROYED or not can_control:
		return
	
	Tutorial.on_first_attack()
	locking_on_target = false
	if selected_target and selected_target.lock.visible:
		selected_target.lock.visible = false
	if anatomy.is_targeted:
		locking_on_target = true
		anatomy.lock.visible = true
		Tutorial.on_attack_lock()
		var target_scale := anatomy.scale
		if not animating_target:
			animating_target = true
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(anatomy, "scale", target_scale * 1.35, 0.08)
			tween.tween_property(anatomy, "scale", target_scale * 0.8, 0.05)
			tween.tween_property(anatomy, "scale", target_scale, 0.08)
			tween.tween_callback(func(): 
				anatomy.scale = target_scale
				animating_target = false
			)
	if selected_target != anatomy:
		if arm.is_blocking and blocking_part:
			blocking_part.is_blocking = false
			blocking_part = null
			arm.rest_pos()
		anatomy.is_targeted = true
		anatomy._highlight_target()
			
		if selected_target:
			if selected_target in opponent_anatomy:
				selected_target.is_targeted = false
				selected_target._unhighlight_target()
		selected_target = anatomy
		if can_action:
			_perform_attack(selected_target)
	#else:
		#selected_target = null
		#anatomy.is_targeted = false
		#anatomy._unhighlight_target()

func character_die() -> void:
	pass

extends Control


@export var anchor_x_offset: float = 1000.0


@onready var filter_rect: ColorRect = %Filter
@onready var menu_anchor: Control = %MenuAnchor
@onready var button_holder_1: Control = %ButtonHolder1
@onready var button_holder_2: Control = %ButtonHolder2
@onready var button_holder_3: Control = %ButtonHolder3
@onready var button_holder_1_padding: Control = %ButtonHolder1/HBoxContainer/Padding
@onready var button_holder_2_padding: Control = %ButtonHolder2/HBoxContainer/Padding
@onready var button_holder_3_padding: Control = %ButtonHolder3/HBoxContainer/Padding
@onready var resume_button: CustomMenuButton = %ResumeButton
@onready var restart_button: CustomMenuButton = %RestartButton
@onready var quit_button: CustomMenuButton = %QuitButton

const ANIMATION_DURATION: float = 0.16
const BUTTON_ANIMATION_DURATION: float = 0.12
const TARGET_ALPHA_FLOAT: float = 1.0
const BASE_ALPHA_FLOAT: float = 0.0

var _base_menu_anchor_position_x: float
var _initial_button_holder_modulate_a: float = 0.0
var _initial_padding_min_size_x: float = 640.0
var _final_padding_min_size_x: float = 0.0

var _is_menu_visible: bool = false
var _current_tween: Tween = null


func _ready() -> void:
	_base_menu_anchor_position_x = menu_anchor.position.x

	_initial_button_holder_modulate_a = button_holder_1.modulate.a
	_initial_padding_min_size_x = button_holder_1_padding.custom_minimum_size.x
	
	_initial_button_holder_modulate_a = button_holder_2.modulate.a
	_initial_padding_min_size_x = button_holder_2_padding.custom_minimum_size.x
	
	_initial_button_holder_modulate_a = button_holder_3.modulate.a
	_initial_padding_min_size_x = button_holder_3_padding.custom_minimum_size.x
	
	_reset_state()

	PauseManager.paused.connect(_on_game_paused)
	PauseManager.resumed.connect(_on_game_resumed)
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	mouse_filter = MOUSE_FILTER_IGNORE
	_is_menu_visible = false


func _on_resume_button_pressed() -> void:
	PauseManager.resume()


func _on_restart_button_pressed() -> void:
	SceneSetManager.reload_current_set()


func _on_quit_button_pressed() -> void:
	SceneSetManager.change_set(SceneSets.MENU_MAIN_MENU)


func _reset_state() -> void:
	filter_rect.modulate.a = BASE_ALPHA_FLOAT

	menu_anchor.position.x = _base_menu_anchor_position_x + anchor_x_offset
	
	button_holder_1.modulate.a = BASE_ALPHA_FLOAT
	button_holder_1_padding.custom_minimum_size.x = 640.0
	
	button_holder_2.modulate.a = BASE_ALPHA_FLOAT
	button_holder_2_padding.custom_minimum_size.x = 640.0
	
	button_holder_3.modulate.a = BASE_ALPHA_FLOAT
	button_holder_3_padding.custom_minimum_size.x = 640.0


func _on_game_paused() -> void:
	if _is_menu_visible: return
	
	_is_menu_visible = true
	mouse_filter = MOUSE_FILTER_STOP
	
	_current_tween = create_tween()
	_current_tween.tween_property(filter_rect, "modulate:a", TARGET_ALPHA_FLOAT, ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(menu_anchor, "position:x", _base_menu_anchor_position_x, ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	_current_tween.chain().tween_property(button_holder_1, "modulate:a", 1.0, BUTTON_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(button_holder_1_padding, "custom_minimum_size:x", _final_padding_min_size_x, BUTTON_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	_current_tween.chain().tween_property(button_holder_2, "modulate:a", 1.0, BUTTON_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(button_holder_2_padding, "custom_minimum_size:x", _final_padding_min_size_x, BUTTON_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	_current_tween.chain().tween_property(button_holder_3, "modulate:a", 1.0, BUTTON_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(button_holder_3_padding, "custom_minimum_size:x", _final_padding_min_size_x, BUTTON_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if _current_tween:
			_current_tween.finished.connect(func(): _current_tween = null)

func _on_game_resumed() -> void:
	if not _is_menu_visible: return
	
	_is_menu_visible = false
	mouse_filter = MOUSE_FILTER_IGNORE
	
	_current_tween = create_tween()
	_current_tween.tween_property(filter_rect, "modulate:a", BASE_ALPHA_FLOAT, ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_current_tween.parallel().tween_property(menu_anchor, "position:x", _base_menu_anchor_position_x + anchor_x_offset, ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	if _current_tween:
		_current_tween.finished.connect(func():
			_reset_state()
			_current_tween = null
		)

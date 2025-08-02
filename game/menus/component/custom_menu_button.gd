class_name CustomMenuButton extends Control


signal pressed()


@export var button_text: String = "Text" : set = set_button_text


@onready var button: TextureButton = %Button
@onready var button_text_label: Label = %ButtonText 
@onready var cog_holder: Control = %CogHolder

var active_tween: Tween = null


func _ready():
	_update_button_text_display(button_text)
	
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_mouse_entered)


func set_button_text(value: String) -> void:
	button_text = value
	_update_button_text_display(button_text)


func _update_button_text_display(text: String) -> void:
	if button_text_label:
		button_text_label.text = text


func _on_mouse_entered() -> void:
	if active_tween:
		return
		
	active_tween = create_tween()
	
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	
	active_tween.tween_property(cog_holder, "rotation_degrees", cog_holder.rotation_degrees + 120.0, 0.5)
	
	active_tween.finished.connect(_on_tween_finished)


func _on_button_pressed() -> void:
	pressed.emit()


func _on_tween_finished() -> void:
	if cog_holder.rotation_degrees > 360.0:
		cog_holder.rotation_degrees-= 360.0
	
	active_tween = null

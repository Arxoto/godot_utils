extends Node2D

@onready var someone_hit: Someone = $SomeoneHit
@onready var someone_hurt: Someone = $SomeoneHurt

@onready var label: Label = $VBoxContainer/Label
@onready var clear_btn: Button = $VBoxContainer/ClearBtn
@onready var hit_stop_anim_btn: Button = $VBoxContainer/HitStopAnimBtn

func _ready() -> void:
	clear_btn.pressed.connect(_on_clear_hit_stop)
	hit_stop_anim_btn.pressed.connect(_on_hit_stop_anim_btn_pressed)

func _on_clear_hit_stop() -> void:
	label.text = "empty"
	someone_hit.apply_hitstop(Someone.HitstopType.NA)
	someone_hurt.apply_hitstop(Someone.HitstopType.NA)

func _on_hit_stop_anim_btn_pressed() -> void:
	label.text = "hit_stop_anim"
	someone_hit.apply_hitstop(Someone.HitstopType.ANIM)
	someone_hurt.apply_hitstop(Someone.HitstopType.ANIM)

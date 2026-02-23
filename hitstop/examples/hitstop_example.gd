extends Node2D

@onready var someone_hit: Someone = $SomeoneHit
@onready var someone_hurt: Someone = $SomeoneHurt
@onready var someone_tmp: Someone = $Someone

@onready var label: Label = $VBoxContainer/Label
@onready var clear_btn: Button = $VBoxContainer/ClearBtn
@onready var hit_stop_anim_btn: Button = $VBoxContainer/HitStopAnimBtn
@onready var hit_stop_shake_basic_btn: Button = $VBoxContainer/HitStopShakeBasicBtn
@onready var hit_stop_shake_freeze_btn: Button = $VBoxContainer/HitStopShakeFreezeBtn

func _ready() -> void:
	clear_btn.pressed.connect(_on_btn_pressed.bind(clear_btn.text, Someone.HitstopType.NA))
	hit_stop_anim_btn.pressed.connect(_on_btn_pressed.bind(hit_stop_anim_btn.text, Someone.HitstopType.ANIM))
	hit_stop_shake_basic_btn.pressed.connect(_on_btn_pressed.bind(hit_stop_shake_basic_btn.text, Someone.HitstopType.SHAKE_BASIC))
	hit_stop_shake_freeze_btn.pressed.connect(_on_btn_pressed.bind(hit_stop_shake_freeze_btn.text, Someone.HitstopType.SHAKE_BASIC))

func _on_btn_pressed(msg: String, hitstop_type: Someone.HitstopType) -> void:
	label.text = msg
	someone_hit.apply_hitstop(hitstop_type)
	someone_hurt.apply_hitstop(hitstop_type)
	someone_tmp.apply_hitstop(hitstop_type)

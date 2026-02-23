extends Node2D
# 使用方式：直接运行场景，点击按钮体验不同的打击感实现效果
# 参数修改：在主角色点击角色场景的实例，可调整打击感强度
# 修改 Shader 实现：打开角色场景，手动修改 Body-Icon 挂载的 Shader ，然后在角色脚本中修改对应的调用方法

@onready var someone_hit: Someone = $SomeoneHit
@onready var someone_hurt: Someone = $SomeoneHurt
@onready var someone_tmp: Someone = $Someone

@onready var label: Label = $VBoxContainer/Label
@onready var clear_btn: Button = $VBoxContainer/ClearBtn
@onready var hit_stop_anim_btn: Button = $VBoxContainer/HitStopAnimBtn
@onready var hit_stop_shake_btn: Button = $VBoxContainer/HitStopShakeBtn

func _ready() -> void:
	clear_btn.pressed.connect(_on_btn_pressed.bind(clear_btn.text, Someone.HitstopType.NA))
	hit_stop_anim_btn.pressed.connect(_on_btn_pressed.bind(hit_stop_anim_btn.text, Someone.HitstopType.ANIM))
	hit_stop_shake_btn.pressed.connect(_on_btn_pressed.bind(hit_stop_shake_btn.text, Someone.HitstopType.SHAKE))

func _on_btn_pressed(msg: String, hitstop_type: Someone.HitstopType) -> void:
	label.text = msg
	someone_hit.apply_hitstop(hitstop_type)
	someone_hurt.apply_hitstop(hitstop_type)
	someone_tmp.apply_hitstop(hitstop_type)

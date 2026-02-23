extends Node2D
class_name Someone

@export_enum("attack", "idle", "rotate", "move")
var move_type: String = "idle";

@export var duration_sec: float = 0.1
@export var shake_intensity: float = 4.0
@export var flash_intensity: float = 0.2
@export var aberr_intensity: float = 0.2
@export var impact_intensity: float = 4.0

# signal on_hit()
# signal on_hurt()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var weapon_model: Area2D = $Weapon/WeaponModel
@onready var weapon_collision: CollisionShape2D = $Weapon/WeaponModel/CollisionShape2D
@onready var body_model: Area2D = $Body/BodyModel
@onready var body_collision: CollisionShape2D = $Body/BodyModel/CollisionShape2D

@onready var hitstop_anim: Node = $AnimationPlayer/HitstopAnim
@onready var hitstop_shader_shake: Node = $Body/BodyModel/Icon/HitstopShaderShake

enum HitstopType {
	NA,
	ANIM,
	SHAKE,
}

var current_hitstop_type: HitstopType = HitstopType.NA

func _ready() -> void:
	# weapon_model.area_entered.connect(on_hit.emit.bind())
	# body_model.area_entered.connect(on_hurt.emit.bind())
	weapon_model.area_entered.connect(do_hitstop)
	body_model.area_entered.connect(do_hitstop)

	animation_player.play(move_type)

func apply_hitstop(hitstop_type: HitstopType):
	current_hitstop_type = hitstop_type

func do_hitstop(_area: Area2D):
	if current_hitstop_type == HitstopType.NA:
		return
	elif current_hitstop_type == HitstopType.ANIM:
		hitstop_anim.do_hitstop_anim(duration_sec)
	elif current_hitstop_type == HitstopType.SHAKE:
		# 更换不同的 shader 需要在这里更换对应的方法
		# hitstop_shader_shake.do_hitstop_shake_basic(duration_sec, shake_intensity, flash_intensity, aberr_intensity)
		# hitstop_shader_shake.do_hitstop_shake_transformed(duration_sec, shake_intensity, flash_intensity, aberr_intensity)
		var impact_direction := Vector2.LEFT if self.global_position.x < _area.global_position.x else Vector2.RIGHT
		hitstop_shader_shake.do_hitstop_shake_freeze(duration_sec, shake_intensity, flash_intensity, aberr_intensity, impact_intensity, impact_direction)

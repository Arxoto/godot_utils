extends Node2D
class_name Someone

@export var will_attack: bool = false
@export var duration_sec: float = 0.1
@export var shake_intensity: float = 4.0

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
	SHAKE_BASIC,
	SHAKE_FREEZE,
}

var current_hitstop_type: HitstopType = HitstopType.NA

func _ready() -> void:
	# weapon_model.area_entered.connect(on_hit.emit.bind())
	# body_model.area_entered.connect(on_hurt.emit.bind())
	weapon_model.area_entered.connect(do_hitstop)
	body_model.area_entered.connect(do_hitstop)

	if will_attack:
		animation_player.play("attack")
	else:
		animation_player.play("idle")

func apply_hitstop(hitstop_type: HitstopType):
	current_hitstop_type = hitstop_type

func do_hitstop(_area: Area2D):
	if current_hitstop_type == HitstopType.NA:
		return
	elif current_hitstop_type == HitstopType.ANIM:
		hitstop_anim.do_hitstop_anim(duration_sec)
	elif current_hitstop_type == HitstopType.SHAKE_BASIC:
		hitstop_shader_shake.do_hitstop_shake_basic(shake_intensity, duration_sec)
	elif current_hitstop_type == HitstopType.SHAKE_FREEZE:
		hitstop_shader_shake.do_hitstop_shake_freeze(shake_intensity, duration_sec, Vector2.RIGHT)

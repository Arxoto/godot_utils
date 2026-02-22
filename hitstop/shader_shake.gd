extends Node
class_name HitstopShaderShake

## 若闪白时间较长 0.2 是个比较舒服的值，时间见 shader 中的 flash_val 计算
@export var flash_intensity: float = 0.8

# 配合 sharp_shake.gdshader
@onready var parent: CanvasItem = get_parent()

## 触发震动和闪白效果，使用了 Shader 注意资源共享引发的问题 [br]
## duration_time 取值参考 [method HitstopAnim.trigger_hitstop] [br]
## shake_intensity 取值参考 [br]
## - 4.0 轻微震动，适用于小打击 [br]
func do_hitstop_shake_basic(shake_intensity: float = 4.0, duration_time: float = 0.1) -> void:
	var start_time := ShaderManager.current_time
	parent.set_instance_shader_parameter("start_time", start_time)
	parent.set_instance_shader_parameter("duration_time", duration_time)
	parent.set_instance_shader_parameter("shake_intensity", shake_intensity)
	parent.set_instance_shader_parameter("flash_intensity", flash_intensity)

func do_hitstop_shake_freeze(shake_intensity: float = 4.0, duration_time: float = 0.1, direction: Vector2 = Vector2.RIGHT) -> void:
	var start_time := ShaderManager.current_time
	parent.set_instance_shader_parameter("start_time", start_time)
	parent.set_instance_shader_parameter("duration_time", duration_time)
	parent.set_instance_shader_parameter("shake_intensity", shake_intensity)
	parent.set_instance_shader_parameter("flash_intensity", flash_intensity)
	parent.set_instance_shader_parameter("impact_direction", direction.normalized())

# todo 验证 震动 色散 等效果

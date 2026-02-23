extends Node
## 通过 Shader 实现的 hitstop 效果 [br]
## 优点： [br]
## - 纯视觉效果不涉及复杂的网络同步 [br]
## - 批处理友好、性能极佳 [br]
## 缺点： [br]
## - Shader 直接作用的节点有缩放旋转等操作时会有显示问题 [br]
##   - 在 GdScript 手动处理坐标变换，以代码复杂度换取性能优势 [br]
##   - 直接使用 CanvasGroup （ GdShader 需适配），性能不高但效果统一 [br]
class_name HitstopShaderShake

# 配合 sharp_shake.gdshader
@onready var parent: CanvasItem = get_parent()

## 触发震动和闪白效果，使用了 Shader 注意资源共享引发的问题 [br]
## duration_time 取值参考 [method HitstopAnim.trigger_hitstop] [br]
## shake_intensity 取值 4.0 轻微震动，适用于小打击 [br]
## flash_intensity 取值 0.2 ，闪白会掩盖震动，一般色散与闪白用一个即可 [br]
## aberr_intensity 取值 0.2 ，色散会放大震动，一般色散与闪白用一个即可 [br]
func do_hitstop_shake_basic(
	duration_time: float = 0.1,
	shake_intensity: float = 4.0,
	flash_intensity: float = 0.2,
	aberr_intensity: float = 0.2,
) -> void:
	var start_time := ShaderManager.current_time
	parent.set_instance_shader_parameter("start_time", start_time)
	parent.set_instance_shader_parameter("duration_time", duration_time)
	parent.set_instance_shader_parameter("shake_intensity", shake_intensity)
	parent.set_instance_shader_parameter("flash_intensity", flash_intensity)
	parent.set_instance_shader_parameter("aberr_intensity", aberr_intensity)

func do_hitstop_shake_freeze(
	duration_time: float = 0.1,
	shake_intensity: float = 4.0,
	flash_intensity: float = 0.0,
	direction: Vector2 = Vector2.RIGHT
) -> void:
	var start_time := ShaderManager.current_time
	parent.set_instance_shader_parameter("start_time", start_time)
	parent.set_instance_shader_parameter("duration_time", duration_time)
	parent.set_instance_shader_parameter("shake_intensity", shake_intensity)
	parent.set_instance_shader_parameter("flash_intensity", flash_intensity)
	parent.set_instance_shader_parameter("impact_direction", direction.normalized())

# todo 验证 震动 色散 等效果

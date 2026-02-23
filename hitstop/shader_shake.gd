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

## 触发震动和色散和闪白效果，使用了 Shader 注意资源共享引发的问题 [br]
## duration_time 取值参考 [method HitstopAnim.do_hitstop_anim] [br]
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

## 若 Shader 挂载的节点有进行缩放和旋转变换，则使用该函数进行修正（同时挂载对应 Shader ）
func do_hitstop_shake_transformed(
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

	# 如果子节点进行了缩放或旋转，则根据受击方向进行修正
	# 水平方向，具体左右并不重要，因为 Shader 中实现为震荡，可能为负数
	var impact_direction: Vector2 = Vector2.RIGHT

	# 矩阵运算处理形变
	var impact_v_world := impact_direction.normalized()
	var impact_v_local := (parent.global_transform as Transform2D).affine_inverse().basis_xform(impact_v_world)
	parent.set_instance_shader_parameter("fix_direction", impact_v_local)

	# # 空间逆运算（物理模拟，更直观但性能稍差）
	# # 1. 计算在世界空间中，受击后的目标位置点
	# var world_source := parent.global_position as Vector2
	# var world_target := world_source + impact_direction
	# # 2. 将世界目标点转回该 Sprite 的局部空间坐标
	# # to_local 会自动处理该 Sprite 的 global_rotation, global_scale 和 skew
	# var local_source := parent.to_local(world_source) as Vector2
	# var local_target := parent.to_local(world_target) as Vector2
	# # 3. 得到局部空间下的位移向量
	# # 这个向量在 Shader 里的 VERTEX 坐标系下，视觉表现正好等于世界空间的偏移
	# var local_v := local_target - local_source
	# parent.set_instance_shader_parameter("fix_direction", local_v)

## 触发震动和色散和闪白效果，使用了 Shader 注意资源共享引发的问题 [br]
## duration_time 取值参考 [method HitstopAnim.do_hitstop_anim] [br]
## shake_intensity 取值 4.0 轻微震动，适用于小打击 [br]
## flash_intensity 取值 0.2 ，闪白会掩盖震动，一般色散与闪白用一个即可 [br]
## aberr_intensity 取值 0.2 ，色散会放大震动，一般色散与闪白用一个即可 [br]
## impact_intensity 取值 4.0 ，轻微卡顿 [br]
## impact_direction 受击方向，控制击退方向 [br]
func do_hitstop_shake_freeze(
	duration_time: float = 0.1,
	shake_intensity: float = 4.0,
	flash_intensity: float = 0.0,
	aberr_intensity: float = 0.2,
	impact_intensity: float = 4.0,
	impact_direction: Vector2 = Vector2.RIGHT,
) -> void:
	var start_time := ShaderManager.current_time
	parent.set_instance_shader_parameter("start_time", start_time)
	parent.set_instance_shader_parameter("duration_time", duration_time)
	parent.set_instance_shader_parameter("shake_intensity", shake_intensity)
	parent.set_instance_shader_parameter("flash_intensity", flash_intensity)
	parent.set_instance_shader_parameter("aberr_intensity", aberr_intensity)
	parent.set_instance_shader_parameter("impact_intensity", impact_intensity)
	parent.set_instance_shader_parameter("impact_direction", impact_direction)

extends Node
# 应该 AutoLoad as ShaderManager

## 周期设定为 12 小时
const RESET_PERIOD: float = 43200.0

var current_time: float = 0.0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS # 确保暂停逻辑可控

func _process(delta: float) -> void:
	if not get_tree().paused:
		current_time += delta
		# 定时重置，允许那一瞬间的视觉效果丢失
		if current_time > RESET_PERIOD:
			current_time = 0.0
	# 每帧仅执行一次全局提交给 GPU 应该在【着色器全局值】中设置
	RenderingServer.global_shader_parameter_set("current_time", current_time)

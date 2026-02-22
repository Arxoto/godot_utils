extends Node
# 应该 AutoLoad as ShaderManager

var current_time: float = 0.0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS # 确保暂停逻辑可控

func _process(delta: float) -> void:
	if not get_tree().paused:
		current_time += delta
	# 每帧仅执行一次全局提交给 GPU 应该在【着色器全局值】中设置
	RenderingServer.global_shader_parameter_set("current_time", current_time)

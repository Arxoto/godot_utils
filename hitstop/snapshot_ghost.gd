extends Sprite2D
class_name HitstopShakeB

# 预留参数：根据武器重量调整
@export var hitstop_duration: float = 0.12 # 卡肉持续时间
@export var ghost_offset_x: float = 12.0 # 残影偏移距离

func _spawn_ghost_snap(impact_dir: Vector2):
	# 创建一个视觉副本
	var ghost = Sprite2D.new()
	ghost.texture = texture
	ghost.hframes = hframes
	ghost.vframes = vframes
	ghost.frame = frame
	ghost.flip_h = flip_h
	ghost.global_transform = global_transform
	
	# 设置残影视觉属性
	ghost.modulate = Color(1, 1, 1, 0.5) # 半透明
	ghost.z_index = z_index - 1 # 放在本体后面一层
	
	# 关键：将副本加入场景树
	get_tree().root.add_child(ghost)
	
	# 计算偏移位置 (仅横向)
	# 如果 impact_dir.x > 0 表示向右击退，残影向右偏
	var direction = 1.0 if impact_dir.x > 0 else -1.0
	var target_pos = ghost.global_position + Vector2(direction * ghost_offset_x, 0)
	
	# 补间动画：模拟冲击瞬间的位移延迟感
	var g_tween = create_tween()
	
	# A. 瞬间弹出（由于是视觉副本，此时本体在原地通过Shader震动，看起来像本体裂开了）
	ghost.global_position = target_pos
	
	# B. 保持极短时间后快速缩回到本体位置并消失
	g_tween.tween_interval(hitstop_duration * 0.5)
	g_tween.set_parallel(true)
	# 这里的 global_position 会动态追踪本体当前位置，解决本体移动中的对齐问题
	g_tween.tween_property(ghost, "global_position", global_position, 0.08).set_trans(Tween.TRANS_EXPO)
	g_tween.tween_property(ghost, "modulate:a", 0.0, 0.1)
	
	g_tween.set_parallel(false)
	g_tween.finished.connect(func(): ghost.queue_free())

func spawn_hit_ghost(sprite: Node2D, impact_dir: Vector2):
	# 1. 创建快照
	var ghost = Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.global_transform = sprite.global_transform
	ghost.modulate = Color(1, 1, 1, 0.6) # 半透明
	get_tree().root.add_child(ghost)
	
	# 2. 初始偏移（模拟冲击）
	var offset_pos = ghost.global_position + impact_dir * 8.0
	
	# 3. 补间动画（使用 Tween）
	var tween = create_tween().set_parallel(true)
	# 瞬间移动到偏移位
	ghost.global_position = offset_pos
	# 然后快速回弹并消失
	tween.tween_property(ghost, "global_position", sprite.global_position, 0.1).set_delay(0.05).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(ghost, "modulate:a", 0.0, 0.15).set_delay(0.05)
	
	tween.finished.connect(func(): ghost.queue_free())

# todo
# hitstop 方案选型（纯视觉方案，不影响联机游戏的网络同步）
# 1、着色器震颤，打击感一般、性能好，适用于快节奏动作
# 2、静态快照，打击感强、运行时性能一般，适用于重击特写或大位移
# 3、动态残影，打击感中高、运行时性能一般，兼顾动感与停顿，可用于玩家角色受击

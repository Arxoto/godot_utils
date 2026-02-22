extends Node
class_name HitstopAnim

@onready var anim_player: AnimationPlayer = get_parent()
# var anim_player: AnimationPlayer

var _tween: Tween

# 其生命周期应该与角色绑定，如果必须频繁退出加入树，才考虑放在 _enter_tree 和 _exit_tree 中
func _ready() -> void:
	# anim_player.animation_changed 仅动画队列中的动画切换时触发，手动切换不触发
	anim_player.current_animation_changed.connect(_on_animation_changed) # 动画切换时触发（理论上），包括手动切换，存在 BUG 动画自然结束不触发
	anim_player.animation_finished.connect(_on_animation_changed) # 非循环动画播放到末尾时触发，和上面的互补

# func _enter_tree() -> void:
# 	anim_player = get_parent()
# 	anim_player.current_animation_changed.connect(_on_animation_changed)
# 	anim_player.animation_finished.connect(_on_animation_changed)

# func _exit_tree() -> void:
# 	_kill_tween()
# 	# 断开信号连接
# 	if anim_player:
# 		anim_player.current_animation_changed.disconnect(_on_animation_changed)
# 		anim_player.animation_finished.disconnect(_on_animation_changed)

## 触发顿帧 [br]
## duration_sec 取值参考： [br]
## - 0.04s 在 60 FPS 下约等于 2-3 帧，适用于连击流畅、不影响手感的场景 [br]
## - 0.1s 在 60 FPS 下约等于 6 帧，适用于强调打击感、需要明显反馈的场景 [br]
## - 0.2s 在 60 FPS 下约等于 12 帧，能明显看到放缓动画（如果帧序列足够），适用于特写 [br]
func trigger_hitstop(slow_magnitude: float = 0.05, duration_sec: float = 0.1, recover_sec: float = 0.1, force_hitstop: bool = false) -> void:
	assert(slow_magnitude > 0.0 and slow_magnitude < 1.0, "Slow magnitude must be between 0 and 1")
	assert(duration_sec > 0.0 and duration_sec < 0.3, "Duration must be between 0 and 0.3 seconds")
	assert(recover_sec > 0.0 and recover_sec < 0.3, "Recover must be between 0 and 0.3 seconds")
	
	if force_hitstop: # 强制顿帧
		_kill_tween()
	elif _tween: # 如果正在顿帧，就不处理
		return
	
	# 慢放阶段所损失的逻辑时间
	var lost_time := duration_sec * (1.0 - slow_magnitude)
	# 补偿阶段需要加速追赶的速度（尽可能，不保证完全一致）
	var catch_up_speed := 1.0 + (2.0 * lost_time / recover_sec)
	catch_up_speed = min(catch_up_speed, 3.0) # 最小加速倍数，防止过快的补偿
	
	_tween = create_tween().set_parallel(false).set_ignore_time_scale(true)
	_tween.tween_callback(func(): anim_player.speed_scale = slow_magnitude) # 顿帧
	_tween.tween_interval(duration_sec) # 持续一段时间
	_tween.tween_callback(func(): anim_player.speed_scale = catch_up_speed) # 瞬间切到加速状态
	_tween.tween_property(anim_player, "speed_scale", 1.0, recover_sec).set_trans(Tween.TRANS_LINEAR) # 平滑回归（线性）
	_tween.finished.connect(_kill_tween)

func _kill_tween() -> void:
	if _tween:
		_tween.kill()
		_tween = null

## 信号回调：动画一旦切换，立即强制初始化
func _on_animation_changed(_name: Variant) -> void:
	_kill_tween()
	anim_player.speed_scale = 1.0

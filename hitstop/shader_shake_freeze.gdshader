/*
- 冻结：前20%进度为冻结期，期间x轴击退偏移不变、y轴震动减弱
- 击退：根据受击方向有击退效果
- 震动：先强后缓，与击退方向垂直
- 闪白：先强后缓
- 色散：先强后缓，与击退方向平行
*/

shader_type canvas_item;

// 全局自动同步变量 (需在项目设置中手动添加 Shader Global)
global uniform float current_time;

// 实例独立变量
instance uniform float start_time = -1.0;
instance uniform float duration_time = 0.0;
instance uniform float shake_intensity = 0.0; // 震动偏移 单位是像素
instance uniform float flash_intensity = 0.0; // 闪白的混合系数 不能超过 1
instance uniform float aberr_intensity = 0.0; // 色散相对 UV 坐标的偏移 不能超过 1
instance uniform float impact_intensity = 0.0; // 冲击力度 单位是像素
instance uniform vec2 impact_direction = vec2(1.0, 0.0); // 必须是归一化后的向量

// 所有共享资源的 shader 统一
// 闪白 颜色可调
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float fast_noise(float t) {
    // fract(sin(t) * 43758.5453) - 0.5; // 依赖显卡的三角函数近似算法，部分机器宏观上可能效果不佳
    uint x = floatBitsToUint(t);
    // XOR-Shift 核心逻辑：仅靠异或和位移产生混乱
    x ^= x << 13u;
    x ^= x >> 17u;
    x ^= x << 5u;
    return float(x) * (1.0 / 4294967296.0) - 0.5; // 伪随机数 平均期望值为 0
}

void vertex() {
    // 开始震动后经过的时间
	float elapsed = current_time - start_time;
	// 若现在仍在时间范围内则为 1.0 否则为 0.0
	float mask = step(0.0, elapsed) * step(elapsed, duration_time);
	// 计算进度 (0.0 到 1.0)
	float p = clamp(elapsed / duration_time, 0.0, 1.0);
    
    // 受击瞬间冻结（视觉错觉）
    // 进度 20% 冻结
    float frozen_threshold = 0.2;
    // 值为 6.0 在进度 30% 位移衰减到 55% 脆爽的硬打击感
    // 值为 4.0 在进度 40% 位移衰减到 55% 稍柔和
    const float decay_speed = 6.0;
    float is_frozen = step(p, frozen_threshold) * mask;
    // 冻结期间保持最大 之后指数衰减
    float damping = exp(-max(0.0, p - frozen_threshold) * decay_speed) * mask;
    // 主位移
    vec2 base_push = impact_direction * impact_intensity * damping;
    
    // 高频颤抖 (冻结期不颤抖，或者极微弱颤抖)
    float shake_rand = fast_noise(current_time * 193.0);
    // 颤抖方向垂直于受击方向
    vec2 shake_direction = vec2(-impact_direction.y, impact_direction.x);
    // 只有在非冻结期才释放强力颤抖，冻结期强度减半
    vec2 shake_offset = shake_direction * shake_rand * shake_intensity * damping * (1.0 - is_frozen * 0.5);

    VERTEX += (base_push + shake_offset);
}

void fragment() {
	float elapsed = current_time - start_time;
	float mask = step(0.0, elapsed) * step(elapsed, duration_time);
	float p = clamp(elapsed / duration_time, 0.0, 1.0);
	float flash_val = pow(1.0 - p, 5.0) * flash_intensity * mask; // 极速闪白
	
    // 色散偏移：衰减曲线、杂乱中有节奏
	float aberration_val = pow(1.0 - p, 5.0) * aberr_intensity * mask;
    float t = current_time * 167.0;
    float shift = (sin(t) * 0.7 + fast_noise(t)) * aberration_val;
    float r = texture(TEXTURE, UV + impact_direction * shift).r;
    float g = texture(TEXTURE, UV).g;
    float b = texture(TEXTURE, UV - impact_direction * shift).b;
    float a = texture(TEXTURE, UV).a;
    vec4 tex_color = vec4(r, g, b, a);
	// vec4 tex_color = texture(TEXTURE, UV);

	// 混合 flash_val 为 0 时返回原色
	COLOR = mix(tex_color, vec4(flash_color.rgb, tex_color.a), flash_val);
}

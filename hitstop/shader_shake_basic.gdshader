/*
- 震动：先强后缓，仅x轴震动（自身）
- 闪白：先强后缓
- 色散：先强后缓，仅x轴偏移（自身）
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

	// 爆发式衰减曲线 (1-p)^3
	float shake_val = pow(1.0 - p, 3.0) * shake_intensity * mask;
	// 高频非谐振波动计算
	float t = current_time * 167.0; // 质数 防止与刷新率共振 151 157 163 167 173
	float x_offset = (sin(t) * 0.7 + fast_noise(t)) * shake_val; // 平衡节奏与随机
	
	// 仅在 X 轴上进行高频偏移，模拟横向位移反馈
	VERTEX.x += x_offset;
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
    float r = texture(TEXTURE, UV + vec2(shift, 0.0)).r;
    float g = texture(TEXTURE, UV).g;
    float b = texture(TEXTURE, UV - vec2(shift, 0.0)).b;
    float a = texture(TEXTURE, UV).a;
    vec4 tex_color = vec4(r, g, b, a);
	// vec4 tex_color = texture(TEXTURE, UV);

	// 混合 flash_val 为 0 时返回原色
	COLOR = mix(tex_color, vec4(flash_color.rgb, tex_color.a), flash_val);
}


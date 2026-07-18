extends CharacterBody2D

## 8 方向移动角色控制器
## 支持 上 / 下 / 左 / 右 + 4 个对角线，共 8 个方向输入。
## 因为只有 4 个动画（run_up / run_down / run_left / run_right），
## 对角方向会取“主轴”对应的那个动画播放（见 _update_animation）。

@export var speed := 200.0  # 移动速度（像素/秒），可在编辑器里调

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	# 同时按 上+右 等会得到对角线向量，get_vector 已原生支持 8 方向
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# 归一化：保证斜向移动速度和直行一致（避免对角比直行快 √2 倍）
	velocity = input_dir.normalized() * speed

	if velocity != Vector2.ZERO:
		_update_animation(velocity)
		if not _sprite.is_playing():
			_sprite.play()
	else:
		# 没有 idle 动画时，停下就冻结在某一帧
		_sprite.pause()

	move_and_slide()


## 根据速度方向选播放哪个动画（4 选 1）
func _update_animation(dir: Vector2) -> void:
	var anim: StringName
	if abs(dir.x) > abs(dir.y):
		# 水平分量更大 -> 用左右动画
		anim = "run_left" if dir.x < 0 else "run_right"
	else:
		# 垂直分量更大（对角相等时偏向竖直）-> 用上下动画
		anim = "run_up" if dir.y < 0 else "run_down"

	if _sprite.animation != anim:
		_sprite.play(anim)

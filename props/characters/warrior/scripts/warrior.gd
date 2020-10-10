extends KinematicBody2D

var speed = 4
var maxHealth = 100
var enemyDamage = 25

var ai_think_time = 0.7
var ai_think_time_timer = null


#animacoes
var direction_animation = "sd"
var idle = "idle"
var run = "run"
var attack = "attack"
var _position_last_frame := Vector2()
var _cardinal_direction = 0

var reflexes = 4
onready var target = get_parent().get_node("nakai")
var is_in_range = false

var health = 0

func _onready():
	health = maxHealth;
	setup_ai_think_time_timer()

func _ready():
	_onready()
	setup_ai_think_time_timer()

func take_Damage(damageCount):
	health -= damageCount;
	
	if(health <= 0):
		health = 0
		$AnimationPlayer.play("death_a")
		queue_free()
		
		
func attack():
	var damage = round(randi() % 50 + enemyDamage / 10)
	attack = "attack_" + direction_animation
	$AnimatedSprite.play(attack); 
	target.take_damage(enemyDamage)

func ai_get_direction():
	return target.position - self.position


func ai_move():
	var direction = ai_get_direction() 
	var motion = direction.normalized() * speed
	
	run = "run_" + direction_animation
	
	move_and_collide(motion);
	$AnimatedSprite.play(run); 



func _physics_process(delta):
	var motion = position - _position_last_frame
	if motion.length() > 0.0001:
		_cardinal_direction = int(8.0 * (motion.rotated(PI / 8.0).angle() + PI) / TAU)


	match _cardinal_direction:
		0:
		   direction_animation = "a"
		1:
			direction_animation = "wa"
		2:
			direction_animation = "w"
		3:
		   direction_animation = "wd"
		4:
			direction_animation = "d"
		5:
			direction_animation = "sd"
		6:
			direction_animation = "s"
		7:
			direction_animation = "sa"

	_position_last_frame = position
	
	

func setup_ai_think_time_timer():
	ai_think_time_timer = Timer.new()
	ai_think_time_timer.set_one_shot(true)
	ai_think_time_timer.set_wait_time(ai_think_time)
	ai_think_time_timer.connect("timeout", self, "on_ai_thinktime_timeout_complete")
	add_child(ai_think_time_timer)

func decide_to_attack():
	ai_think_time_timer.start()
	
func on_ai_thinktime_timeout_complete():
	if is_in_range:
		attack()

func _process(delta):
		ai_move()


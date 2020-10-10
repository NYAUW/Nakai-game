extends KinematicBody2D

var speed = 5
var maxHealth = 100
var enemyDamage = 25

var ai_think_time = 0.7
var ai_think_time_timer = null

var direction_animation = "sd"
var idle = "idle"
var run = "run"

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
		$AnimationPlayer.play("die")
		queue_free()
		
		
func attack():
	var damage = round(randi() % 50 + enemyDamage / 10)
	target.take_damage(damage);

func ai_get_direction():
	return target.position - self.position


func ai_move():
	var direction = ai_get_direction()
	var motion = direction.normalized() * speed
		
	run = "run_" + direction_animation
		
	move_and_collide(motion);
	$AnimatedSprite.play(run); 
	
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
	if is_in_range && ai_think_time_timer.time_left == 0:
		decide_to_attack()
	else:
		ai_move()
	


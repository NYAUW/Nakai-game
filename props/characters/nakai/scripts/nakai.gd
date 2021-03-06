extends KinematicBody2D


const  MOTION_SPEED = 4
var speed = MOTION_SPEED

var direction_animation = "sd"
var idle = "idle_sd"
var run = "run_sd"
var death = "death"
var roll = "idle_sd"
var attack = "attack_sd"
var damage = 0;
var attack_type = 0;
var collision
var _position_last_frame := Vector2()
var _cardinal_direction = 0
onready var energy_bar = get_parent().get_node("nakai/Camera2D/GUI/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/StaminaBar/MarginContainer/Label/TextureProgress")
onready var health_bar = get_parent().get_node("nakai/Camera2D/GUI/HBoxContainer/VBoxContainer/MarginContainer2/MarginContainer/HealthBar/MarginContainer/Label/TextureProgress")
onready var target
var in_roll = false;
var health = 1000.0
var energy = 1000.0
var is_attack = false;
var death_state = false
var energy_discaunt = false

var vel_roll = Vector2(0,0)
var damage_caused = null;
var attacked = false;



func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y)/1.7 )

func _on_Timer_timeout():
	in_roll = false
	speed = MOTION_SPEED

func _on_Timer_attack_timeout():
	is_attack = false
	attacked = false

func _physics_process(delta):
	
	if (death_state == false):
		var motion = Vector2()
		
		if Input.is_action_pressed("move_up") and in_roll == false and is_attack == false:
			motion += Vector2(-1, -1)
					
		if Input.is_action_pressed("move_down") and in_roll == false and is_attack == false:
			motion += Vector2(1, 1)

		if Input.is_action_pressed("move_left") and in_roll == false and is_attack == false:
			motion += Vector2(-1, 1)
			
		if Input.is_action_pressed("move_right") and in_roll == false and is_attack == false:
			motion += Vector2(1, -1)
		
		if in_roll == true:
			motion += vel_roll

		if Input.is_action_just_pressed("roll"):
			if(energy_bar.value >= 200.0):
				in_roll = true
				energy_discaunt = true
				energy = round(energy - 200)
				speed = 4.5
				vel_roll = motion
				$Timer.connect("timeout", self, "_on_Timer_timeout")
				$Timer.start()
		
		if Input.is_action_just_pressed("attack_one") and energy_bar.value >= 210:
			if(energy_bar.value >= 210):	
				attack_type = 1;
				is_attack = true
				damage_caused = 340;
				energy = round(energy - 210)
				update_energy(energy)
				$Timer_attack.wait_time = 1.5
				init_timer_attack()
				
		if Input.is_action_just_pressed("attack_two") and energy_bar.value >= 180:
			if(energy_bar.value >= 180):
				attack_type = 2;
				is_attack = true
				damage_caused = 280
				energy= round(energy - 180)
				update_energy(energy)
				$Timer_attack.wait_time = 1
				init_timer_attack()
				
		if Input.is_action_just_pressed("attack_tree"):
			if(energy_bar.value >= 350):
				attack_type = 3;
				is_attack = true
				damage_caused = 450
				energy = round(energy - 350)
				update_energy(energy)
				$Timer_attack.wait_time = 1.90
				init_timer_attack()
				
		

		if motion !=  Vector2(0, 0): 
			
			var motion_direction = position - _position_last_frame
			if motion.length() > 0.0001:
				_cardinal_direction = int(8.0 * (motion_direction.rotated(PI / 8.0).angle() + PI) / TAU)
			
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
			
			idle = "idle_" + direction_animation
			roll = "roll_" + direction_animation
			run = "run_" + direction_animation
			attack = "attack" + str(attack_type) + "_" + direction_animation

			_position_last_frame = position
			
			if(is_attack == false):
				if in_roll == false:
					$AnimatedSprite.play(run)
				else:
					$AnimatedSprite.play(roll)
					if(energy_discaunt == true):
						print(energy)
						update_energy(energy)
						energy_discaunt = false
		
		else:
			if(is_attack == true):
				$AnimatedSprite.play(attack)
				attack()
			else:
				$AnimatedSprite.play(idle)
				energy_bar.value = energy_bar.value + 0.9 #idle bonus
	
		energy_bar.value = energy_bar.value + 0.5
		energy = energy_bar.value
		health_bar.value = health_bar.value + (1/10)
		health = health_bar.value
		
		if(energy_bar.value > 500): 
			regen_life()

	
		if(is_attack == false):
			motion = motion.normalized()
			motion = cartesian_to_isometric(motion)  * speed
			collision = move_and_collide(motion)
			if(collision != null and collision.collider != null and collision.collider is KinematicBody2D):
				target = collision.collider

	
func take_damage(damage):
	if(death_state == false):
		if(health_bar.value <= 0):
			death_state = true
			death = "death_" + direction_animation
			$AnimatedSprite.play(death)
		#else:
			#health= round(health - damage)
			#update_health(health)
	
func update_energy(new_value):
	energy_bar.value = new_value
	
func update_health(new_value):
	health_bar.value = new_value
	
func regen_life():
	health_bar.value = health_bar.value + 0.06
	health = health_bar.value

func init_timer_attack():		
	$Timer_attack.connect("timeout", self, "_on_Timer_attack_timeout")
	$Timer_attack.start()

func attack():
	damage = damage_caused;
	if(target != null):
		var direction = target.direction
		var distance_direction = sqrt(direction.x * direction.x + direction.y * direction.y)
		var ready_to_attack = ($AnimatedSprite.frame == 17 || $AnimatedSprite.frame == 18 || $AnimatedSprite.frame == 19  || $AnimatedSprite.frame == 20  || $AnimatedSprite.frame == 21  || $AnimatedSprite.frame == 22  || $AnimatedSprite.frame == 23  || $AnimatedSprite.frame == 24) and distance_direction < 100 and attacked == false
		#var space_state = get_world_2d().direct_space_state
		#var sight_check = space_state.intersect_ray(position, distance_direction, self)
		if(ready_to_attack == true):
			if(collision != null):
				print(collision.collider.name)
				target.take_Damage(damage)
				update_energy(energy)
				attacked = true
			_on_Timer_attack_timeout()

extends KinematicBody2D

const GRAVITY = 10
const JUMP_POWER = -250
const FLOOR = Vector2(0, -1)
const FIREBALL = preload("res://FireBall.tscn")

var velocity = Vector2()
var SPEED = 60
var on_ground = false
var attacking = false
var look_up = false
var dead = false

 
func dead():
	dead = true
	$CollisionShape2D.disabled = true
	velocity = Vector2(0, 0)
	$AnimatedSprite.play("Dead")
	$Timer.start()

func _physics_process(delta):
	var fireball = FIREBALL.instance()
	
	if dead == false:
			
		if Input.is_action_pressed("ui_sprint"):
			SPEED = 120
		else:
			SPEED = 60
		if Input.is_action_pressed("ui_right"):
			if attacking == false:
				velocity.x = SPEED
				$AnimatedSprite.play("Run")
				$AnimatedSprite.flip_h = false
				if sign($Position2D.position.x) == -1:
					$Position2D.position.x *= -1
		elif Input.is_action_pressed("ui_left"):
			if attacking == false:
				velocity.x = -SPEED
				$AnimatedSprite.play("Run")
				$AnimatedSprite.flip_h = true
				if sign($Position2D.position.x) == 1:
						$Position2D.position.x *= -1
						
		else:
			velocity.x = 0
			if on_ground == true && attacking == false:
				$AnimatedSprite.play("Idle")
				look_up = false
			
			
		if Input.is_action_pressed("ui_jump"):
				if on_ground == true:
					velocity.y = JUMP_POWER
					on_ground = false
			
		velocity.y = velocity.y + GRAVITY
		if Input.is_action_pressed("ui_up"):
			if on_ground == true:
				$AnimatedSprite.play("LookUp")
				look_up = true

		if is_on_floor():
			on_ground = true
		else:
			if attacking == false:
				on_ground = false
				if velocity.y < 0:
					$AnimatedSprite.play("Jump")
				else: 
					$AnimatedSprite.play("Fall")
				
		if Input.is_action_just_pressed("ui_attack") && attacking == false:
			attacking = true
			$AnimatedSprite.play("Attack")
			if sign($Position2D.position.x) == 1:
				fireball.set_fireball_direction(1)
			else:
				fireball.set_fireball_direction(-1)
			get_parent().add_child(fireball)
			fireball.position = $Position2D.global_position
				
			if Input.is_action_pressed("ui_exit"):
				get_tree().change_scene("res://TitleScreen.tscn")

		
		velocity = move_and_slide(velocity, FLOOR)
		
		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				if "Villan" in get_slide_collision(i).collider.name:
					dead()
					
		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				if "Pit" in get_slide_collision(i).collider.name:
					dead()

func sprint():
	pass
func _on_AnimatedSprite_animation_finished():
	attacking = false

func _on_Timer_timeout():
	get_tree().change_scene("res://TitleScreen.tscn")

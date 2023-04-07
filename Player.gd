extends KinematicBody2D

enum{
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var cvelocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

export var FRICTION = 800
export var MAX_SPEED = 100
export var ACCELERATION = 600
export var ROLL_SPEED = 125

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var Hurtbox = $Hurtbox

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		cvelocity = cvelocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		cvelocity = cvelocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationState.travel("Idle")
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	cvelocity = Vector2.ZERO
	animationState.travel("Attack")
	pass

func move():
	cvelocity = move_and_slide(cvelocity)

func roll_state(delta):
	cvelocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	pass
	
func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.set_health(1)
	Hurtbox.start_invincibility(0.5)
	Hurtbox.create_hit_effect()

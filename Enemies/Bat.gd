extends KinematicBody2D

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var Hurtbox = $Hurtbox

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum{
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state : 
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seekplayer()
			
		WANDER:
			pass
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				sprite.flip_h = velocity.x < 0
			else:
				state = IDLE

	velocity = move_and_slide(velocity)

func seekplayer():
	if playerDetectionZone.can_see_player():
		state = CHASE
	
	pass

func _on_Hurtbox_area_entered(area):
	stats.health = area.damage
	knockback = area.knockback_vector * 140
	Hurtbox.start_invincibility(0.01)
	Hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

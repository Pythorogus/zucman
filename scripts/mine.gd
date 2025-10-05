extends Node
class_name Mine

signal explode

@export var vfx_explosion: Node3D
@export var model: Node3D
@export var bip_sfx: AudioStreamPlayer3D

var laser
var triggered = false

func _ready():
	for child in get_children():
		if child is Laser:
			laser = child
			child.player_touched.connect(_on_player_touched)

func _on_player_touched():
	if !triggered:
		trigger_laser()
		trigger_explode()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if laser and !triggered:
		trigger_laser()
	trigger_explode()

func trigger_laser():
	triggered = true
	laser.visible = false

func trigger_explode():
	bip_sfx.play()
	await get_tree().create_timer(0.3).timeout # attendre 1.5s
	vfx_explosion.explode()
	model.visible = false
	explode.emit()

extends Node3D
class_name VfxExplosion
@export var sparks: GPUParticles3D
@export var flash: GPUParticles3D
@export var smoke: GPUParticles3D
@export var fire: GPUParticles3D
@export var explosion_sfx: AudioStreamPlayer3D

func explode():
	sparks.emitting = true
	flash.emitting = true
	smoke.emitting = true
	fire.emitting = true
	explosion_sfx.play()

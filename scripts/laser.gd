extends Node3D
class_name Laser

signal player_touched

@export var ray_cast: RayCast3D
@export var scaler: Node3D

var distance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var collider = ray_cast.get_collider()
	if collider:
		if collider.name == "Player":
			player_touched.emit()
		else:
			distance = transform.origin.distance_to(to_local(ray_cast.get_collision_point()))
			scaler.scale.z = distance / 1.5
	else:
		print("scaler ok")
		scaler.scale.z = 1000
	

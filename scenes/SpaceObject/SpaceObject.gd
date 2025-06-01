extends CharacterBody3D
class_name SpaceObject

@onready var mesh: MeshInstance3D = $mesh
@onready var coll: CollisionShape3D = $coll
var mass = 100
var rotation_speed = 0.0  # радианы в секунду

# period — период вращения в игровых днях (например, 1 день для Земли)
# day_duration — сколько секунд реального времени соответствует одному игровому дню
func set_material(patch_material: String, new_mass: float = 100, period: float = 1.0, day_duration: float = 1.0) -> void:
	var material = StandardMaterial3D.new()
	material.albedo_texture = load(patch_material)
	material.albedo_color = Color.WHITE
	material.metallic = 0.2
	material.roughness = 0.8

	mesh.material_override = material
	
	mass = new_mass
	# Рассчитываем угловую скорость вращения в радианах в секунду:
	# rotation_speed = 2π / (period * day_duration)
	rotation_speed = 2 * PI / (period * day_duration)

func _process(delta: float) -> void:
	if rotation_speed != 0.0 and mesh:
		mesh.rotate_y(rotation_speed * delta)

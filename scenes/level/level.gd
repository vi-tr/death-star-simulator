extends Node3D

const DAY_DURATION := 10.0  # секунд на один игровой день
const G := 6.67430e-11  # гравитационная постоянная (м3/кг/c2)
const SCALE_DISTANCE := 1.496e9  # 1 а.е. в метрах (примерно)

func _ready():
	$sun.set_material("res://assets/sun_texture.jpg", 1.989e30, 25.0, DAY_DURATION)
	$earth.set_material("res://assets/earth-texture.jpg", 5.972e24, 1.0, DAY_DURATION)
	$moon.set_material("res://assets/moon-texture.jpg", 7.35e22, 27.3, DAY_DURATION)
	
	$earth.position = Vector3(-2.700742859439665e10, 1.446007021429538e11, 9.687450725421309e06) / SCALE_DISTANCE
	$earth.velocity = Vector3(-2.977044214085218e04, -5.568042062189587e03, 3.960050738736065e-01) / SCALE_DISTANCE
	
	$moon.position = Vector3(-2.739180166063208e10, 1.445252142564551e11, -5.966407747305930e06) / SCALE_DISTANCE
	$moon.velocity = Vector3(-2.951549140447329e04, -6.529794009827214e03, -7.615838122417218e01) / SCALE_DISTANCE
func _process(delta: float) -> void:
	print("Earth vel: ", $earth.velocity)
	
	var planets = find_children("*", "SpaceObject", true, false)
	
	for planet in planets:
		var acceleration = Vector3.ZERO
		for other_planet in planets:
			if planet != other_planet:
				var radius_vector = other_planet.position - planet.position
				var r_dist = radius_vector.length()
				var r_dist_norm = radius_vector.normalized()
				
				acceleration += G * other_planet.mass * (radius_vector / (r_dist ** 3 + 0.001)) / (SCALE_DISTANCE ** 2)
		planet.velocity += acceleration * delta
		planet.position += planet.velocity * delta
		

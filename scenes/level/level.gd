extends Node3D

const DAY_DURATION := 1.0  # секунд на один игровой день
const G := 6.67430e-11  # гравитационная постоянная (м3/кг/c2)
const SCALE_DISTANCE := 1.496e9  # 1 а.е. в метрах (примерно)

func _ready():
	$sun.set_material("res://assets/sun_texture.jpg", 1.989e30, 25.0, DAY_DURATION)
	$earth.set_material("res://assets/earth-texture.jpg", 5.972e24, 1.0, DAY_DURATION)
	$moon.set_material("res://assets/moon-texture.jpg", 7.35e22, 27.3, DAY_DURATION)


func _process(delta: float) -> void:
	print("Earth vel: ", $earth.velocity)

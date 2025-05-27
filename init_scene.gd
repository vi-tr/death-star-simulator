extends Node3D

# Настройки камеры
@export var mouse_sensitivity := 0.002
@export var move_speed := 5.0
@export var sprint_speed := 10.0
@export var vertical_speed := 3.0

var _current_speed := move_speed
var _yaw := 0.0
var _pitch := 0.0

func _ready():
	# Настройка окружения (оптимизированная)
	setup_optimized_environment()
	
	# Создание объектов (с оптимизацией)
	var sun = create_optimized_sphere(200.0, "res://assets/sun_texture.jpg", Vector3(300, 0, 0), true)
	var earth = create_optimized_sphere(2.0, "res://assets/earth-texture.jpg", Vector3(10, 0, 0))
	var moon = create_optimized_sphere(0.2, "res://assets/moon-texture.jpg", Vector3(13, 0, 0))
	
	# Камера
	setup_fps_camera()

func setup_optimized_environment():
	var env = WorldEnvironment.new()
	add_child(env)
	
	# Упрощенное небо без HDRI
	var sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.01, 0.01, 0.05)
	sky_material.sky_horizon_color = Color(0, 0, 0)
	sky.sky_material = sky_material
	
	# Оптимизированные настройки окружения
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.01, 0.01, 0.05)
	environment.ambient_light_energy = 0.02
	environment.ambient_light_color = Color(0.03, 0.03, 0.1)
	
	# Отключаем тяжелые эффекты
	environment.sdfgi_enabled = false
	environment.ssao_enabled = false
	environment.ssil_enabled = false
	
	# Минимальные эффекты свечения
	environment.glow_enabled = true
	environment.glow_intensity = 0.8
	environment.glow_strength = 1.0
	environment.glow_bloom = 0.05
	
	env.environment = environment
	
	# Простое звездное поле через MeshInstance
	create_simple_star_field()

func create_simple_star_field():
	var star_mesh = SphereMesh.new()
	star_mesh.radius = 1000
	star_mesh.height = 2000
	
	var star_mat = StandardMaterial3D.new()
	star_mat.albedo_texture = create_star_texture()
	star_mat.emission_enabled = true
	star_mat.emission = Color(1, 1, 1)
	star_mat.emission_energy = 0.5
	
	var stars = MeshInstance3D.new()
	stars.mesh = star_mesh
	stars.mesh.material = star_mat
	add_child(stars)

func create_star_texture():
	var image = Image.create(1024, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 1))
	
	var rng = RandomNumberGenerator.new()
	for i in 2000:
		var x = rng.randi_range(0, 1023)
		var y = rng.randi_range(0, 511)
		var brightness = rng.randf_range(0.3, 1.0)
		image.set_pixel(x, y, Color(brightness, brightness, brightness))
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func create_optimized_sphere(radius: float, texture_path: String, position: Vector3, is_sun: bool = false) -> MeshInstance3D:
	var sphere = MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	sphere.mesh.radius = radius
	sphere.mesh.height = radius * 2
	
	# Уменьшаем детализацию для больших объектов
	if radius > 50:
		sphere.mesh.radial_segments = 32
		sphere.mesh.rings = 32
	else:
		sphere.mesh.radial_segments = 24
		sphere.mesh.rings = 24
	
	var material = StandardMaterial3D.new()
	var texture = load(texture_path)
	
	if texture:
		material.albedo_texture = texture
		material.albedo_color = Color.WHITE
	
	if is_sun:
		material.emission_enabled = true
		material.emission = Color(1, 0.85, 0.7)
		material.emission_energy = 3.0
		
		# Простой источник света без теней
		var sun_light = OmniLight3D.new()
		sun_light.light_energy = 30.0
		sun_light.omni_range = 500
		sun_light.shadow_enabled = false
		sphere.add_child(sun_light)
	else:
		material.metallic = 0.2
		material.roughness = 0.8
	
	sphere.mesh.material = material
	sphere.position = position
	add_child(sphere)
	return sphere

func setup_fps_camera():
	var camera = Camera3D.new()
	camera.name = "FPS_Camera"
	camera.far = 10000.0
	camera.near = 0.1
	camera.current = true
	add_child(camera)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -1.5, 1.5)
		$FPS_Camera.rotation = Vector3(_pitch, _yaw, 0)
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	# Управление движением
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	

	
	var direction = ($FPS_Camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Вертикальное движение
	var vertical = 0.0
	
	$FPS_Camera.global_translate((direction * _current_speed + Vector3(0, vertical, 0) * vertical_speed * delta))

extends Spatial

const SIZE = 320;

func _ready():
	generate_island()
	
	
func generate_island():
	randomize()
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	var noise = OpenSimplexNoise.new()
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(SIZE,SIZE)
	plane_mesh.subdivide_depth = SIZE / 2;
	plane_mesh.subdivide_width = SIZE / 2;
	
	noise.seed = randi()
	
	noise.octaves = 5;
	noise.period  = 120;
	
	
	surface_tool.create_from(plane_mesh,0)
	var array_mesh = surface_tool.commit()
	data_tool.create_from_surface(array_mesh,0)
	
	
	
	var gradient_mask = CustomGradientTexture.new()
	gradient_mask.gradient = Gradient.new()
	gradient_mask.type = CustomGradientTexture.GradientType.RADIAL
	gradient_mask.size = Vector2(SIZE+1, SIZE+1)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	#$WaterLevel.scale = Vector3(SIZE,1,SIZE)
	
	for i in range(data_tool.get_vertex_count()):
		
		var vertex = data_tool.get_vertex(i)
		var value = noise.get_noise_3d(vertex.x,vertex.y,vertex.z);
		
		var data = gradient_mask.get_data()
		data.lock();
		var gradient_value = data.get_pixel(vertex.x + SIZE * 0.5,vertex.z+ SIZE * 0.5).g * 1.5
		
		var limit = 0.5
		
		if gradient_value >= limit:
			gradient_value = limit
		
		value -= gradient_value
		
		vertex.y = value * 50
		vertex.y = vertex.y + 15.931;
		
		if vertex.y >= 10:
			vertex.y = vertex.y - vertex.y / 45
		
		data.unlock()
		
		if(vertex.y > -47):
			var grass = load("res://Prefabs/Grass.tscn")
			var grass_resource = grass.instance()
			grass_resource.translation = Vector3(vertex.x + rng.randf_range(-0.5, 0.5),vertex.y,vertex.z + rng.randf_range(-0.5, 0.5) )
			
		
		data_tool.set_vertex(i,vertex)
	
	for s in range(array_mesh.get_surface_count()):
		array_mesh.surface_remove(s)
	
	data_tool.commit_to_surface(array_mesh)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_mesh,0)
	surface_tool.generate_normals()
	
	var material = preload("res://Resources/IslandMaterial.tres")
	
	# we load the material here go the the asset dierectory for more info on how the island is rendered, might have to fix to move from gles3 to gles2!
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.material_override = material
	
	#mesh_instance.scale = Vector3(256,mesh_instance.scale.y,256)
	
	self.add_child(mesh_instance)
	
	$WaterLevel.scale = Vector3(512,$WaterLevel.scale.y,512)
	
	

extends Node2D

var circles = []

var dragging_index = -1
var drag_offset =  Vector2.ZERO

func is_colliding(circle_a, circle_b):
	var distance = circle_a["position"].distance_to(circle_b["position"])
	var minimum_distance = circle_a["radius"]+circle_b["radius"]
	return distance < minimum_distance

func is_position_valid(dragged_circle, new_position):
	var new_dragged_circle = {
			"position": new_position, 
			"radius": dragged_circle["radius"]
	}
	for circle in circles:
		if circle == dragged_circle:
			continue
			
		if is_colliding(circle, new_dragged_circle):
			return false
	return true

func resolve_collisions(index, candidate_position):
	var dragged_circle = circles[index]
	for iteration in range(6):
		for i in range(circles.size()):
			if i == index:
				continue
			
			var other_circle = circles[i]
			var minimum_distance = dragged_circle["radius"] + other_circle["radius"]
			var difference = candidate_position - other_circle["position"]
			var distance = difference.length()
			
			if distance >= minimum_distance:
				continue
				
			var direction = difference.normalized()
			
			if direction == Vector2.ZERO:
				direction = (dragged_circle["position"] - other_circle["position"]).normalized()
				
				if direction == Vector2.ZERO:
					direction = Vector2.RIGHT
			
			candidate_position = other_circle["position"] + direction * minimum_distance
	return candidate_position

func _ready():
	var spawn_button = Button.new()
	spawn_button.text = "Spawn Circle"
	spawn_button.position = Vector2(20, 20)
	spawn_button.size = Vector2(140, 40)
	add_child(spawn_button)
	spawn_button.pressed.connect(_on_spawn_button_pressed)

func _draw():
	for circle in circles:
		draw_circle(circle["position"], circle["radius"], Color.WHITE)

func _on_spawn_button_pressed():
	var viewport_size = get_viewport_rect().size
	var radius = 50.0
	
	circles.append({
		"position": Vector2(
			randf_range(radius, viewport_size.x - radius),
			randf_range(radius, viewport_size.y - radius)
		),
		"radius": radius
	})
	
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		
		if not event.pressed:
			dragging_index = -1
			return
			
		for i in range(circles.size()):
			var circle = circles[i]
			
			if circle["position"].distance_to(event.position) <= circle["radius"]:
				dragging_index = i
				drag_offset = circle["position"] - event.position
				return
			
	elif event is InputEventMouseMotion:
		if dragging_index == -1:
			return
		
		var circle = circles[dragging_index]
		var desired_position = event.position + drag_offset
		
		circle["position"] = resolve_collisions(dragging_index, desired_position)
		circles[dragging_index] = circle
		
		queue_redraw()
		return

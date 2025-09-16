extends Control

@export var grid_size_x: float = 45.7
@export var grid_size_y: float = 45.0
@export var grid_color: Color = Color(1, 1, 1, 0.5)
@export var number_color: Color = Color(1, 1, 1, 0.8)
@export var axis_color: Color = Color(1, 0, 0, 0.8)
@export var grid_lines: int = 26
@export var max_x_lines: float = 45.74
@export var max_y_lines: float = 13.77
@export var font: Font
@export var font_size: int = 16

func _draw():
	# Define the "center" index (middle of grid_lines)
	var center_x = int(grid_lines / 2.0)
	var center_y = int((grid_lines - 11) / 2.0)

	# Draw vertical lines
	for x in range(grid_lines + 1):
		var xpos = x * grid_size_x
		var line_color = axis_color if x == center_x else grid_color
		draw_line(Vector2(xpos, 0), Vector2(xpos, max_y_lines * grid_size_x), line_color)

		# Numbering: shift so center = 0
		var number = x - center_x
		var num_color = axis_color if number == 0 else number_color
		draw_string(font, Vector2(xpos + 2, -4), str(number), HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, num_color)

	# Draw horizontal lines
	for y in range(grid_lines - 11):
		var ypos = y * grid_size_y
		var line_color = axis_color if y == center_y else grid_color
		draw_line(Vector2(0, ypos), Vector2(grid_lines * max_x_lines, ypos), line_color)

		# Numbering: shift so center = 0, flip sign for Y
		var number = center_y - y
		var num_color = axis_color if number == 0 else number_color
		draw_string(font, Vector2(-28, ypos + 12), str(number), HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, num_color)

func _process(_delta):
	queue_redraw()

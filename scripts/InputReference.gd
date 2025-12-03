extends Resource
class_name InputRef
@export var platform: NodePath
@export_enum("x", "y") var axis: String
@export_enum("+", "-", "*", "/") var operation: String = "+"
@export var index: int = -1

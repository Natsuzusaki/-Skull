extends Node

@onready var label: Label = $"../Terminal/Panel/MarginContainer/VBoxContainer/HBoxContainer/Label"
var control_regex = RegEx.new()
#DO NOT TOUCH!!!
#var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
#var variable_names = []
#var loop_var_names = []
#var valid_var_regex = RegEx.new()
#var loop_var_regex = RegEx.new()
#func code_verify(code: String, header: String) -> bool: 
	#loop_var_names.clear() #empties variable array
	#variable_names.clear()
	#loop_var_regex.clear() #empties regex
	#valid_var_regex.clear()
	#var_collector(header)
	#var lines = code.split("\n")
#
	#for line in lines:
		#line.strip_edges()
		##print(line) #individual debug
		##Checking syntax errors on control methods
		#control_regex.compile("^(if|elif|else|for|while|match|case)\\b")
		#if control_regex.search(line) and not line.ends_with(":"):
			#label.text = "Missing ':'"
			#return false
		#control_regex.compile("^(print)")
		#if control_regex.search(line) and (not line.contains("(") or not line.contains(")")):
			#label.text = "Missing parethesis in print"
			#return false
		#if (line.contains("(") and not line.contains(")")) or (line.contains(")") and not line.contains("(")):
			#label.text = "Missing a parethesis"
			#return false
		##Checking variables inside user code
		#control_regex.compile("^(var|const|for)")
		#if control_regex.search(line):
			#var_collector(line)
		##print(loop_var_names)
		##print(variable_names)
#
		##Checking for if-else errors
		#control_regex.compile("^(if|elif)")
		#if control_regex.search(line):
			#if not valid_var_regex.search(line):
				#label.text = "Variable out of scope \n in if() or elif()"
				#return false
		#control_regex.compile("^(else:)")
		#if line.contains("else") and not control_regex.search(line):
			#label.text = "Expected ':' after else"
			#return false
		##Checking for print errors
		#control_regex.compile('^(print()')
		#if line.contains("print") and not control_regex.search(line):
			#if line.contains("print()"):
				#pass
			#elif (line.contains('("') and not line.ends_with('")')) or (line.ends_with('")') and not line.contains('("')):
				#label.text = 'Missing `"` in print()'
				#return false
			#elif (line.contains("('") and not line.ends_with("')")) or (line.ends_with("')") and not line.contains("('")):
				#label.text = "Missing `'` in print()"
				#return false
			#elif (not line.contains('"') and not line.contains("'")) and not valid_var_regex.search(line) and not loop_var_regex.search(line):
				#var num = false
				#for valid in numbers:
					#num = true if line.contains(valid) else false
					#if num:
						#break
				#if not num:
					#label.text = "Variable out of scope \n in print()"
					#return false
		##Checking for for loop errors
		#control_regex.compile("^(for)")
		#if control_regex.search(line):
			#var parts = line.split(" in")
			#if valid_var_regex.search(parts[0]):
				#label.text = "Variable already exist! \n Cannot be in 'for <var> in'"
				#return false
			#if parts[1].contains("range("):
				#if parts[1].contains("range()"):
					#label.text = "Expexted at least \n 1 argument, non given \n in range()"
					#return false
				#var range_part = parts[1].split("range(")
				#var num = false
				#for valid in numbers:
					#num = true if range_part[1].contains(valid) else false
					#if num:
						#break
				#if not num:
					#label.text = "Invalid range! \n must be an integer"
					#return false
			#elif not control_regex.search(parts[1]) and not valid_var_regex.search(parts[1]):
				#control_regex.compile("(range)")
				#if control_regex.search(parts[1]):
					#label.text = "Missing parenthesis \n in range"
					#return false
				#else:
					#label.text = "Variable out of scope \n in for loop"
					#return false
		##Checking for while loop errors
		#control_regex.compile("^(while)")
		#if control_regex.search(line):
			#pass
	#control_regex.compile("^(if|elif|else|for|while|match|case|print|var|const)\\b")
	#if not control_regex.search(code):
		#label.text = "Input not declared \n in the current scope"
		#return false
	#return true
#func var_collector(code: String) -> void:
	#control_regex.compile("^(var|const)")
	#var variables = code.split("\n")
	#for variable in variables:
		#variable = variable.strip_edges()
		#if control_regex.search(variable):
			#var parts = variable.split(" =")
			#var name_parts = parts[0].split(" ")
			#if name_parts.size() > 1 and not valid_var_regex.search(name_parts[1]):
				#variable_names.append(name_parts[1])
				#update_regex(0)
		#elif variable.begins_with("for"):
			#var parts = variable.split(" in")
			#var name_parts = parts[0].split(" ")
			#if name_parts.size() > 1 and not loop_var_regex.search(name_parts[1]) and not valid_var_regex.search(name_parts[1]):
				#loop_var_names.append(name_parts[1])
				#update_regex(1)
#func update_regex(what: int) -> void:
	#if what:
		#loop_var_regex.compile("\\b(" + "|".join(loop_var_names) + ")\\b")
	#else:
		#valid_var_regex.compile("\\b(" + "|".join(variable_names) + ")\\b")

func auto_indentation(user_code: String, _limit: int) -> String:
	control_regex.compile(r"print\s*\(([^)]*)\)")
	#if user_code.begins_with('print("') and user_code.ends_with('")'):
		#user_code = text_limiter(user_code, limit)
	var result = user_code
	for match in control_regex.search_all(user_code):
		var inner = match.get_string(1)
		var replacement = "custom_print([%s])" % inner
		result = result.replace(match.get_string(), replacement)
	user_code = result
	#user_code = user_code.replace("print(", "custom_print(")
	#user_code = control_regex.sub(user_code, "custom_print([\\1])", true)
	if func_detector(user_code):
		var indented_lines = []
		var lines = user_code.split("\n")
		var indentation_level = 1
		for line in lines:
			indented_lines.append("\t".repeat(indentation_level) + line)
		return "\n".join(indented_lines)
	else:
		label.text = "Error: Console can't \n handle functions"
		return ""

func func_detector(user_code: String) -> bool:
	var lines = user_code.split("\n")
	control_regex.compile("^(func)")
	for line in lines:
		if control_regex.search(line):
			return false
	return true

#func text_limiter(user_code: String, limit: int) -> String:
	#var regex = RegEx.new()
	#regex.compile("\"([^\"]*)\"|'([^']*)'")
	#var result := ""
	#var last_pos := 0
	#for match in regex.search_all(user_code):
		#var start := match.get_start()
		#var end := match.get_end()
		#result += user_code.substr(last_pos, start - last_pos)
		#var content := match.get_string(1)
		#if content == "":
			#content = match.get_string(2)
		#if content.length() > limit:
			#content = content.substr(0, limit)
		#var quote := user_code.substr(start, 1)
		#result += "%s%s%s" % [quote, content, quote]
		#last_pos = end
	#result += user_code.substr(last_pos)
	#return result

func code_verify(error) -> bool:
	if error == Error.ERR_PARSE_ERROR:
		label.text = "Parse Error: \n Check your syntax!"
		return true
	elif error == Error.ERR_COMPILATION_FAILED:
		label.text = "Compilation Error: \n There is a semantic error!"
		return true
	elif error != OK:
		label.text = "Script Error: \n IDK where tho 😋"
		return true
	return false

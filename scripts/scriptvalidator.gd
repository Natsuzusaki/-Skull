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
	var result = user_code
	for match in control_regex.search_all(user_code):
		var inner = match.get_string(1)
		var replacement = "custom_print([%s])" % inner
		result = result.replace(match.get_string(), replacement)
	user_code = result
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

func code_verify(error) -> bool:
	if error == Error.ERR_PARSE_ERROR:
		SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ERROR)
		label.text = "Parse Error: \n Check your syntax!"
		return true
	elif error == Error.ERR_COMPILATION_FAILED:
		SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ERROR)
		label.text = "Compilation Error: \n There is a semantic error!"
		return true
	elif error != OK:
		SfxManager.play_sfx(sfx_settings.SFX_NAME.CONSOLE_ERROR)
		label.text = "Script Error: \n IDK where tho 😋"
		return true
	return false

func preprocess_array_access(code: String) -> String:
	var processed = code

	var re_set := RegEx.new()
	re_set.compile(r"(\w+)\s*\[\s*([^\]]+)\s*\]\s*=\s*([^\n]+)")
	for match in re_set.search_all(processed):
		var obj = match.get_string(1)
		var idx = match.get_string(2)
		var val = match.get_string(3)
		var replacement = "%s.set_at(%s, %s)" % [obj, idx, val]
		processed = processed.replace(match.get_string(), replacement)

	var re_get := RegEx.new()
	re_get.compile(r"(\w+)\s*\[\s*([^\]]+)\s*\]")
	for match in re_get.search_all(processed):
		var obj = match.get_string(1)
		var idx = match.get_string(2)
		var replacement = "%s.get_at(%s)" % [obj, idx]
		processed = processed.replace(match.get_string(), replacement)

	var re_for := RegEx.new()
	re_for.compile(r"for\s+(\w+)\s+in\s+(\w+)\s*:")
	for match in re_for.search_all(processed):
		var varname = match.get_string(1)
		var arrname = match.get_string(2)
		var replacement = "for %s in %s.inputs:" % [varname, arrname]
		processed = processed.replace(match.get_string(), replacement)

	return processed

func rewrite_code(user_code: String) -> String:
	user_code = preprocess_array_access(user_code)
	var rewritten = user_code

	var regex_x = RegEx.new()
	regex_x.compile(r"(\w+)\.position\.x\s*=\s*([^\n]+)")
	for match in regex_x.search_all(rewritten):
		var obj = match.get_string(1)
		var val = match.get_string(2)
		rewritten = rewritten.replace(match.get_string(),
			"%s.set_grid_x(%s)" % [obj, val])

	var regex_y = RegEx.new()
	regex_y.compile(r"(\w+)\.position\.y\s*=\s*([^\n]+)")
	for match in regex_y.search_all(rewritten):
		var obj = match.get_string(1)
		var val = match.get_string(2)
		rewritten = rewritten.replace(match.get_string(),
			"%s.set_grid_y(%s)" % [obj, val])

	var regex_vec = RegEx.new()
	regex_vec.compile(r"(\w+)\.position\s*=\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)")
	for match in regex_vec.search_all(rewritten):
		var obj = match.get_string(1)
		var x = match.get_string(2)
		var y = match.get_string(3)
		rewritten = rewritten.replace(
			match.get_string(),
			"%s.commanded_position = Vector2(%s, %s)" % [obj, x, y]
		)
	rewritten = rewritten.replace(".position", ".commanded_position")

	var loop_regex := RegEx.new()
	loop_regex.compile(r"while\s+([^\:]+):")
	var matches = loop_regex.search_all(rewritten)
	var safe_code = rewritten
	for m in matches:
		var condition = m.get_string(1)
		var original_line = "while %s:" % condition
		var replacement = "var __loop_count = 0\n\t%s\n\t\t__loop_count += 1\n\t\tif __loop_count > 50:\n\t\t\tconsole.label.text = \"⚠️ Loop too long (max:50)\"\n\t\t\tbreak" % original_line
		safe_code = safe_code.replace(original_line, replacement)
	rewritten = safe_code

	return rewritten

func detect_infinite_loops(user_code: String) -> bool:
	var lines: Array = user_code.split("\n")
	var loop_regex := RegEx.new()
	loop_regex.compile(r"(?m)^\s*while\s+(.+):")
	for i in range(lines.size()):
		var line: String = str(lines[i])
		var match := loop_regex.search(line)
		if not match:
			continue
		var condition_raw: String = match.get_string(1).strip_edges()
		var condition: String = condition_raw.to_lower()
		if condition == "true":
			if not _has_break_or_yield(lines, i):
				return true
			else:
				continue
		var cond_vars: Array = _get_condition_vars(condition_raw)
		if cond_vars.is_empty():
			if not _has_break_or_yield(lines, i):
				return true
			else:
				continue
		var comparator: String = _extract_comparator(condition_raw)
		var body_lines: Array = lines.slice(i + 1, min(i + 12, lines.size()))
		var body_text: String = " ".join(body_lines).to_lower()
		if body_text.find("break") != -1 or body_text.find("yield") != -1 or body_text.find("await") != -1:
			continue
		var any_var_safe := false
		for v_raw in cond_vars:
			var v: String = v_raw.to_lower()
			var aug_regex := RegEx.new()
			aug_regex.compile(r"%s\s*([\+\-])=\s*([0-9]+(?:\.[0-9]+)?)" % v)
			for m in aug_regex.search_all(body_text):
				var op := m.get_string(1)
				var num := float(m.get_string(2))
				if abs(num) > 0.000001:
					var dir := 1 if (op == "+") else -1
					if _direction_matches(comparator, dir):
						any_var_safe = true
						break
			if any_var_safe:
				break
			var assign_regex := RegEx.new()
			assign_regex.compile(r"%s\s*=\s*(.+)" % v)
			for m in assign_regex.search_all(body_text):
				var rhs_raw: String = m.get_string(1).strip_edges()
				if rhs_raw.find(v) == -1:
					any_var_safe = true
					break
				var rhs_for_eval: String = _replace_var_with_zero(rhs_raw, v)
				var net_change: float = _evaluate_math(rhs_for_eval)
				if abs(net_change) <= 0.000001:
					continue
				var dir := 1 if (net_change > 0.0) else -1
				if _direction_matches(comparator, dir):
					any_var_safe = true
					break
			if any_var_safe:
				break
		if not any_var_safe:
			return true
	return false

func _has_break_or_yield(lines: Array, start_idx: int) -> bool:
	for j in range(start_idx + 1, min(start_idx + 12, lines.size())):
		var l: String = str(lines[j]).strip_edges().to_lower()
		if "break" in l or "yield" in l or "await" in l:
			return true
	return false

func _get_condition_vars(condition: String) -> Array:
	var vars: Array = []
	var word_regex := RegEx.new()
	word_regex.compile(r"\b[a-zA-Z_]\w*\b")
	for m in word_regex.search_all(condition):
		var w: String = m.get_string()
		var lw := w.to_lower()
		if lw in ["and", "or", "not", "true", "false"]:
			continue
		vars.append(w)
	return vars

func _extract_comparator(cond: String) -> String:
	var comps := [">=", "<=", ">", "<"]
	for c in comps:
		if c in cond:
			return c
	return ""

func _direction_matches(comp: String, dir: int) -> bool:
	if comp == "<" or comp == "<=":
		return dir > 0
	if comp == ">" or comp == ">=":
		return dir < 0
	return dir != 0

func _replace_var_with_zero(rhs: String, varname: String) -> String:
	var out := rhs
	var rhs_lower := rhs.to_lower()
	var var_lower := varname.to_lower()
	var word_regex := RegEx.new()
	word_regex.compile(r"\b%s\b" % var_lower)
	for m in word_regex.search_all(rhs_lower):
		var start := m.get_start()
		var end := m.get_end()
		out = out.substr(0, start) + "0" + out.substr(end)
	return out

func _evaluate_math(expr: String) -> float:
	var s: String = expr.strip_edges()
	if s == "":
		return 0.0
	var tokens: Array[String] = []
	var i: int = 0
	while i < s.length():
		var ch: String = s[i]
		if ch == " ":
			i += 1
			continue
		if _is_digit(ch) or ch == "." or (ch == "-" and (i == 0 or s[i - 1] in ["(", "+", "-", "*", "/"])):
			var numstr: String = ""
			if ch == "-":
				numstr += "-"
				i += 1
			while i < s.length() and (_is_digit(s[i]) or s[i] == "."):
				numstr += s[i]
				i += 1
			tokens.append(numstr)
			continue
		if ch in ["+", "-", "*", "/", "(", ")"]:
			tokens.append(ch)
		i += 1
	var out_queue: Array[String] = []
	var op_stack: Array[String] = []
	for t: String in tokens:
		if _is_number_string(t):
			out_queue.append(t)
		elif t in ["+", "-", "*", "/"]:
			while op_stack.size() > 0 and op_stack[-1] != "(" and _prec(op_stack[-1]) >= _prec(t):
				out_queue.append(op_stack.pop_back())
			op_stack.append(t)
		elif t == "(":
			op_stack.append(t)
		elif t == ")":
			while op_stack.size() > 0 and op_stack[-1] != "(":
				out_queue.append(op_stack.pop_back())
			if op_stack.size() > 0 and op_stack[-1] == "(":
				op_stack.pop_back()
	while op_stack.size() > 0:
		out_queue.append(op_stack.pop_back())
	var eval_stack: Array[float] = []
	for tk: String in out_queue:
		if _is_number_string(tk):
			eval_stack.append(float(tk))
		else:
			if eval_stack.size() < 2:
				return 0.0
			var b: float = eval_stack.pop_back()
			var a: float = eval_stack.pop_back()
			match tk:
				"+": eval_stack.append(a + b)
				"-": eval_stack.append(a - b)
				"*": eval_stack.append(a * b)
				"/":
					if absf(b) < 0.000001:
						eval_stack.append(0.0)
					else:
						eval_stack.append(a / b)
				_: eval_stack.append(0.0)
	return eval_stack[0] if eval_stack.size() > 0 else 0.0

func _is_digit(ch: String) -> bool:
	return ch >= "0" and ch <= "9"

func _is_number_string(s: String) -> bool:
	if s.is_empty():
		return false
	if s == "-" or s == ".":
		return false
	for c: String in s:
		if not ((c >= "0" and c <= "9") or c == "." or c == "-"):
			return false
	return true

func _prec(op: String) -> int:
	match op:
		"+", "-": return 1
		"*", "/": return 2
		_: return 0

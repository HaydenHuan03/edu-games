extends Node

var project_url = ""
var anon_key = ""

func _ready():
	load_env("res://scripts/api/.env")
	fetch_questions()
	submit_battle_result("47f80a8a-2777-4ddb-9646-0bc62d0881be", true)

func load_env(path: String):
	if not FileAccess.file_exists(path):
		push_error("env not found, path: " + path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts = line.split("=", false, 1)
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()
			value = value.strip_edges().trim_prefix('"').trim_suffix('"')
			if key == "projectURL":
				project_url = value
			elif key == "anon":
				anon_key = value
	file.close()

func fetch_questions():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	var url = project_url + "/rest/v1/questions?select=*"
	var headers = [
		"apikey: " + anon_key,
		"Authorization: Bearer " + anon_key
	]

	var error = http_request.request(url, headers)
	if error != OK:
		print("Request failed to send, error code: ", error)

func _on_request_completed(result, response_code, headers, body):
	print("HTTP status code: ", response_code)
	var json_string = body.get_string_from_utf8()
	print("Response body: ", json_string)

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var data = json.data
		print("Parsed successfully, number of questions: ", data.size())
		for question in data:
			print("Question: ", question["question_text"])
	else:
		print("Failed to parse JSON")
		
func submit_battle_result(question_id: String, is_correct: bool):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_submit_completed)

	var url = project_url + "/rest/v1/battles"
	var headers = [
		"apikey: " + anon_key,
		"Authorization: Bearer " + anon_key,
		"Content-Type: application/json",
		"Prefer: return=representation"
	]

	var body = {
		"user_id": "01d3174e-aa74-4f71-8d58-3dbc5dd8d075",
		"question_id": question_id,
		"is_correct": is_correct,
		"result": "win" if is_correct else "lose"
	}
	var json_body = JSON.stringify(body)

	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("Submit request failed to send, error code: ", error)

func _on_submit_completed(_result, response_code, _headers, body):
	print("Submit HTTP status code: ", response_code)
	print("Submit response body: ", body.get_string_from_utf8())

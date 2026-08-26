extends Node

signal signup_success(user_id: String)
signal signup_failed(error_message: String)
signal login_success(user_id: String, access_token: String)
signal login_failed(error_message: String)

var access_token: String = ""
var refresh_token: String = ""
var current_user_id: String = ""

func _project_url() -> String:
	return Env.get_value("projectURL")

func _anon_key() -> String:
	return Env.get_value("anon")

func sign_up(email: String, password: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_signup_completed.bind(http_request))

	var url = _project_url() + "/auth/v1/signup"
	var headers = ["apikey: " + _anon_key(), "Content-Type: application/json"]
	var body = JSON.stringify({"email": email, "password": password})
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_signup_completed(_result, response_code, _headers, body, http_request):
	http_request.queue_free()
	var json = JSON.parse_string(body.get_string_from_utf8())

	if response_code == 200:
		emit_signal("signup_success", json.get("id", ""))
	else:
		var msg = json.get("msg", json.get("error_description", "注册失败,请重试"))
		emit_signal("signup_failed", msg)

func sign_in(email: String, password: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_login_completed.bind(http_request))

	var url = _project_url() + "/auth/v1/token?grant_type=password"
	var headers = ["apikey: " + _anon_key(), "Content-Type: application/json"]
	var body = JSON.stringify({"email": email, "password": password})
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_login_completed(_result, response_code, _headers, body, http_request):
	http_request.queue_free()
	var json = JSON.parse_string(body.get_string_from_utf8())

	if response_code == 200:
		access_token = json.get("access_token", "")
		refresh_token = json.get("refresh_token", "")
		var user = json.get("user", {})
		current_user_id = user.get("id", "")
		emit_signal("login_success", current_user_id, access_token)
	else:
		var msg = json.get("error_description", json.get("msg", "登录失败,账号或密码错误"))
		emit_signal("login_failed", msg)

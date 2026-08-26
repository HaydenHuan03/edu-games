extends Control

@onready var login_email: LineEdit = $TabContainer/Login/LoginEmail
@onready var login_password: LineEdit = $TabContainer/Login/LoginPassword
@onready var login_button: Button = $TabContainer/Login/LoginButton
@onready var login_status: Label = $TabContainer/Login/LoginStatus

@onready var signup_email: LineEdit = $TabContainer/SignUp/SignUpEmail
@onready var signup_password: LineEdit = $TabContainer/SignUp/SignUpPassword
@onready var signup_confirm: LineEdit = $TabContainer/SignUp/SignUpConfirmPassword
@onready var signup_button: Button = $TabContainer/SignUp/SignUpButton
@onready var signup_status: Label = $TabContainer/SignUp/SignUpStatus

func _ready():
	print("[AuthScreen] _ready() called, wiring up signals")
	login_button.pressed.connect(_on_login_pressed)
	signup_button.pressed.connect(_on_signup_pressed)
	AuthManager.login_success.connect(_on_login_success)
	AuthManager.login_failed.connect(_on_login_failed)
	AuthManager.signup_success.connect(_on_signup_success)
	AuthManager.signup_failed.connect(_on_signup_failed)
	print("[AuthScreen] signals connected")

func _on_login_pressed():
	print("[AuthScreen] Login button pressed")
	var email = login_email.text.strip_edges()
	var password = login_password.text
	print("[AuthScreen] Login attempt with email: ", email)

	if email == "" or password == "":
		print("[AuthScreen] Login blocked: empty email or password")
		login_status.text = "Please enter email and password"
		return

	login_status.text = "Logging in..."
	login_button.disabled = true
	print("[AuthScreen] Calling AuthManager.sign_in()")
	AuthManager.sign_in(email, password)

func _on_login_success(user_id: String, _access_token: String):
	print("[AuthScreen] _on_login_success fired, user_id: ", user_id)
	login_button.disabled = false
	login_status.text = "Login successful"
	# Next step: navigate to the main scene
	# get_tree().change_scene_to_file("res://scenes/battle/battle_main.tscn")

func _on_login_failed(error_message: String):
	print("[AuthScreen] _on_login_failed fired: ", error_message)
	login_button.disabled = false
	login_status.text = error_message

func _on_signup_pressed():
	print("[AuthScreen] Signup button pressed")
	var email = signup_email.text.strip_edges()
	var password = signup_password.text
	var confirm = signup_confirm.text
	print("[AuthScreen] Signup attempt with email: ", email)

	if email == "" or password == "":
		print("[AuthScreen] Signup blocked: empty email or password")
		signup_status.text = "Please enter email and password"
		return
	if password != confirm:
		print("[AuthScreen] Signup blocked: passwords do not match")
		signup_status.text = "Passwords do not match"
		return
	if password.length() < 6:
		print("[AuthScreen] Signup blocked: password too short")
		signup_status.text = "Password must be at least 6 characters"
		return

	signup_status.text = "Signing up..."
	signup_button.disabled = true
	print("[AuthScreen] Calling AuthManager.sign_up()")
	AuthManager.sign_up(email, password)

func _on_signup_success(_user_id: String):
	print("[AuthScreen] _on_signup_success fired, user_id: ", _user_id)
	signup_button.disabled = false
	signup_status.text = "Signup successful! Check your email to confirm (or try logging in directly)."

func _on_signup_failed(error_message: String):
	print("[AuthScreen] _on_signup_failed fired: ", error_message)
	signup_button.disabled = false
	signup_status.text = error_message

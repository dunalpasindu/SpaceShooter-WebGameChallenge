extends Control

func _ready():
	# Clear error message
	$Panel/VBoxContainer/ErrorMsg.text = ""

func _on_login_button_pressed():
	var email = $Panel/VBoxContainer/EmailInput.text
	var password = $Panel/VBoxContainer/PasswordInput.text
	var error_msg = $Panel/VBoxContainer/ErrorMsg
	
	# Validate input
	if email.is_empty():
		error_msg.text = "Please enter your email"
		return
		
	if password.is_empty():
		error_msg.text = "Please enter your password"
		return
	
	# Disable buttons while logging in
	$Panel/VBoxContainer/HBoxContainer/LoginButton.disabled = true
	$Panel/VBoxContainer/HBoxContainer/RegisterButton.disabled = true
	error_msg.text = "Logging in..."
	
	# First check if the user exists
	if not user_exists(email):
		_on_login_failed("USER_NOT_FOUND", "User not found. Please register first.")
		return
		
	# If user exists, check if password matches
	if verify_login(email, password):
		# Save the user's email to a session file
		var config = ConfigFile.new()
		config.set_value("user", "email", email)
		config.save("user://user_data.cfg")
		
		_on_login_succeeded()
	else:
		_on_login_failed("INVALID_PASSWORD", "Incorrect password. Please try again.")

func _on_register_button_pressed():
	var email = $Panel/VBoxContainer/EmailInput.text
	var password = $Panel/VBoxContainer/PasswordInput.text
	var error_msg = $Panel/VBoxContainer/ErrorMsg
	
	# Validate input
	if email.is_empty():
		error_msg.text = "Please enter your email"
		return
		
	if password.is_empty():
		error_msg.text = "Please enter your password"
		return
	
	# Disable buttons while registering
	$Panel/VBoxContainer/HBoxContainer/LoginButton.disabled = true
	$Panel/VBoxContainer/HBoxContainer/RegisterButton.disabled = true
	error_msg.text = "Registering..."
	
	# Check if user already exists
	if user_exists(email):
		_on_register_failed("EMAIL_EXISTS", "This email is already registered")
		return
		
	# Register the new user
	if register_user(email, password):
		_on_register_succeeded()
	else:
		_on_register_failed("REGISTRATION_ERROR", "Could not register user")

func _on_login_succeeded():
	# Navigate to main menu
	get_tree().change_scene_to_file("res://main.tscn")

func _on_login_failed(error_code, error_message):
	var error_msg = $Panel/VBoxContainer/ErrorMsg
	
	# Enable buttons again
	$Panel/VBoxContainer/HBoxContainer/LoginButton.disabled = false
	$Panel/VBoxContainer/HBoxContainer/RegisterButton.disabled = false
	
	# Display specific error based on error code
	match error_code:
		"USER_NOT_FOUND":
			error_msg.text = error_message
			# Highlight the register button to guide the user
			$Panel/VBoxContainer/HBoxContainer/RegisterButton.grab_focus()
		"INVALID_PASSWORD":
			error_msg.text = error_message
			# Focus the password field for convenience
			$Panel/VBoxContainer/PasswordInput.grab_focus()
		_:
			error_msg.text = "Login failed: " + error_message

func _on_register_succeeded():
	var error_msg = $Panel/VBoxContainer/ErrorMsg
	
	# Enable buttons again
	$Panel/VBoxContainer/HBoxContainer/LoginButton.disabled = false
	$Panel/VBoxContainer/HBoxContainer/RegisterButton.disabled = false
	
	# Show success message
	error_msg.text = "Registration successful! You can now log in."
	error_msg.add_theme_color_override("font_color", Color(0.2, 0.7, 0.2))

func _on_register_failed(error_code, error_message):
	var error_msg = $Panel/VBoxContainer/ErrorMsg
	
	# Enable buttons again
	$Panel/VBoxContainer/HBoxContainer/LoginButton.disabled = false
	$Panel/VBoxContainer/HBoxContainer/RegisterButton.disabled = false
	
	# Display error
	error_msg.text = "Registration failed: " + error_message

# Function to verify login credentials
func verify_login(email: String, password: String) -> bool:
	var config = ConfigFile.new()
	var users_file = "user://registered_users.cfg"
	
	# Check if users file exists
	if not FileAccess.file_exists(users_file):
		return false
		
	# Load users database
	var err = config.load(users_file)
	if err != OK:
		return false
	
	# Check if user exists and password matches
	if config.has_section(email):
		var stored_password = config.get_value(email, "password", "")
		return password == stored_password
	
	return false

# Function to check if a user already exists
func user_exists(email: String) -> bool:
	var config = ConfigFile.new()
	var users_file = "user://registered_users.cfg"
	
	# If users file doesn't exist, user doesn't exist
	if not FileAccess.file_exists(users_file):
		return false
		
	# Load users database
	var err = config.load(users_file)
	if err != OK:
		return false
	
	return config.has_section(email)

# Function to register a new user
func register_user(email: String, password: String) -> bool:
	var config = ConfigFile.new()
	var users_file = "user://registered_users.cfg"
	
	# Load existing users if the file exists
	if FileAccess.file_exists(users_file):
		var err = config.load(users_file)
		if err != OK:
			return false
	
	# Add the new user
	config.set_value(email, "password", password)
	config.set_value(email, "registered_date", Time.get_datetime_string_from_system())
	
	# Save the updated users database
	var err = config.save(users_file)
	return err == OK

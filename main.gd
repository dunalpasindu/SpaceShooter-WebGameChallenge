extends Node2D

@onready var world_scene = preload("res://scenes/world.tscn")

func _ready():
	# Check if user is logged in
	check_login_status()
	
	# Display current user if logged in
	display_current_user()

# Check if user is logged in locally, redirect to login screen if not
func check_login_status():
	if not is_user_logged_in():
		get_tree().change_scene_to_file("res://scenes/login.tscn")

# Display current user's email in the UI
func display_current_user():
	if is_user_logged_in():
		var config = ConfigFile.new()
		var err = config.load("user://user_data.cfg")
		if err == OK:
			var email = config.get_value("user", "email", "unknown")
			$UserLabel.text = email
		else:
			$UserLabel.text = "User: unknown"
	else:
		$UserLabel.text = "User: unknown"

func is_user_logged_in() -> bool:
	# Check if user data file exists
	return FileAccess.file_exists("user://user_data.cfg")

func _on_logout_pressed():
	# Logout locally
	logout_user()

func logout_user():
	# Delete the user data file to log out
	if FileAccess.file_exists("user://user_data.cfg"):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("user_data.cfg")
	
	# Redirect to login screen
	get_tree().change_scene_to_file("res://scenes/login.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_settings_pressed() -> void:
	# TODO: Implement settings screen navigation
	print("Settings button pressed")
	# get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_credits_pressed() -> void:
	# TODO: Implement credits screen navigation
	print("Credits button pressed")
	# get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_leaderboard_pressed() -> void:
	# Navigate to leaderboard scene
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")

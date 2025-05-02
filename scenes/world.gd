extends Node2D

@onready var game_over_label = $"Control/LabelGameOver"
@onready var score_label = $"Control/LabelScore" # Reference to the score label
@onready var high_score_label = $"Control/LabelHighScore" # Reference to the high score label
@onready var error_label = $"Control/ErrorMessage" # Reference to the error message label
@onready var exit_label = $"Control/ExitLabel" # Reference to the exit label
@onready var restart_label = $"Control/RestartLabel" # Reference to the restart label
var score = 0
var high_score = 0
var is_game_over = false

func _ready():
	reset_value()
	# Load the current user's high score at game start
	load_high_score()
	
	# Disable the built-in score update in label_score.gd
	if score_label and score_label.has_method("set_process"):
		score_label.set_process(false)
	
	# Initialize score label
	update_score_label()
	update_high_score_label()

func _process(delta):
	# Handle score display in this script instead of label_score.gd
	update_score_label()
	
	# Handle input for exiting to main menu when game is over
	if is_game_over and Input.is_action_just_pressed("ui_cancel") or (is_game_over and Input.is_key_pressed(KEY_Q)):
		get_tree().change_scene_to_file("res://main.tscn")

func reset_value():
	score = 0
	is_game_over = false
	update_score_label()

func update_score_label():
	score_label.text = "Score: " + str(score) # Update the label text

func update_high_score_label():
	high_score_label.text = "High Score: " + str(high_score) # Update the high score label

func increase_score(amount: int):
	score += amount
	
	# Update high score in real-time if current score exceeds it
	if score > high_score:
		high_score = score
		update_high_score_label()
		
		# Visual feedback when breaking high score
		if high_score_label:
			high_score_label.add_theme_color_override("font_color", Color(1, 0.8, 0))
			# Create a timer to reset the color after 1 second
			var timer = Timer.new()
			timer.wait_time = 1.0
			timer.one_shot = true
			timer.timeout.connect(func(): high_score_label.remove_theme_color_override("font_color"))
			add_child(timer)
			timer.start()

func game_over():
	is_game_over = true
	game_over_label.visible = true
	
	# Show restart and exit instructions
	if restart_label:
		restart_label.visible = true
	if exit_label:
		exit_label.visible = true

	# Get current user's email for user-specific high score file
	var current_user_email = get_current_user_email()
	var sanitized_email = current_user_email.replace("@", "_at_").replace(".", "_dot_")
	
	# Create user-specific high score file path
	var file_path = "user://highscore_" + sanitized_email + ".save"
	var highest_score = 0
	
	# Read existing high score if file exists
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_line()
			highest_score = int(content)
			file.close()
	
	# Save new high score if higher than the existing one
	if score > highest_score:
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_line(str(score))
			file.close()
			print("New high score saved for user " + current_user_email + ": " + str(score))
	else:
		print("Score not saved. Current high score for " + current_user_email + ": " + str(highest_score))

# Function to load the current user's high score at game start
func load_high_score():
	var current_user_email = get_current_user_email()
	var sanitized_email = current_user_email.replace("@", "_at_").replace(".", "_dot_")
	
	# Create user-specific high score file path
	var file_path = "user://highscore_" + sanitized_email + ".save"
	
	# Read existing high score if file exists
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_line()
			high_score = int(content)
			file.close()
			update_high_score_label()
			print("Loaded high score for user " + current_user_email + ": " + str(high_score))
	else:
		high_score = 0
		update_high_score_label()
		print("No previous high score found for user " + current_user_email)

# Function to get the current user's email from the saved user data
func get_current_user_email() -> String:
	var config = ConfigFile.new()
	var err = config.load("user://user_data.cfg")
	if err == OK:
		return config.get_value("user", "email", "unknown")
	return "unknown"

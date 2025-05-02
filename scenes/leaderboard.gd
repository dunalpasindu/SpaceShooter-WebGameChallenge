extends Control

# Reference to the score list container
@onready var scores_list = $Panel/VBoxContainer/ScrollContainer/ScoresList

func _ready():
	# Load and display all player scores
	load_high_scores()

func load_high_scores():
	# Clear any existing scores
	for child in scores_list.get_children():
		child.queue_free()
	
	# Get all the high score files
	var scores = []
	var dir = DirAccess.open("user://")
	
	if dir:
		# List all files in the user directory
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Only process high score files
			if file_name.begins_with("highscore_") and file_name.ends_with(".save"):
				# Extract player name from filename
				var player_name = file_name.replace("highscore_", "").replace(".save", "")
				player_name = player_name.replace("_at_", "@").replace("_dot_", ".")
				
				# Read the score from the file
				var score = read_score_from_file("user://" + file_name)
				
				# Add to scores array
				scores.append({"name": player_name, "score": score})
			
			file_name = dir.get_next()
	
	# Sort scores from highest to lowest
	scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Create UI elements for each score
	var rank = 1
	for score_data in scores:
		add_score_item(rank, score_data.name, score_data.score)
		rank += 1
	
	# If no scores found, display a message
	if scores.size() == 0:
		var no_scores_label = Label.new()
		no_scores_label.text = "No scores found. Play the game to set scores!"
		no_scores_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scores_list.add_child(no_scores_label)

func read_score_from_file(file_path):
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_line()
			file.close()
			return int(content)
	return 0

func add_score_item(rank, player_name, score):
	# Create a horizontal container for this score entry
	var h_box = HBoxContainer.new()
	h_box.size_flags_horizontal = Control.SIZE_FILL
	
	# Rank label
	var rank_label = Label.new()
	rank_label.text = str(rank)
	rank_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rank_label.size_flags_stretch_ratio = 0.3
	
	# Player name label
	var name_label = Label.new()
	name_label.text = player_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Score label
	var score_label = Label.new()
	score_label.text = str(score)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label.size_flags_stretch_ratio = 0.5
	
	# Highlight the top 3 scores
	if rank <= 3:
		var color = Color.WHITE
		match rank:
			1: color = Color(1, 0.8, 0) # Gold
			2: color = Color(0.75, 0.75, 0.75) # Silver
			3: color = Color(0.8, 0.5, 0.2) # Bronze
		
		rank_label.add_theme_color_override("font_color", color)
		name_label.add_theme_color_override("font_color", color)
		score_label.add_theme_color_override("font_color", color)
	
	# Add elements to the row
	h_box.add_child(rank_label)
	h_box.add_child(name_label)
	h_box.add_child(score_label)
	
	# Add the row to the list
	scores_list.add_child(h_box)

func _on_back_button_pressed():
	# Go back to main menu
	get_tree().change_scene_to_file("res://main.tscn")
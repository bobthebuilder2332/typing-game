extends Control

# Waiting for all the child classes to load to avoid errors
@onready var target_label = $TargetWord
@onready var input_label = $InputDisplay
@onready var next_word_label = $NextWord
@onready var stats_label = $StatsLabel
@onready var typed_stat = $TypedStat
@onready var correct_stat = $CorrectStat
@onready var incorrect_stat= $IncorrectStat

# Define variables
var word_list: Array = []
var word_to_type = ""
var typed_words: int = 0
var correct_words: int = 0
var incorrect_words: int = 0
var can_type: bool = true

# Runs when the game starts
func _ready():
	stats_label.visible = false
	typed_stat.visible = false
	correct_stat.visible = false
	incorrect_stat.visible = false
	target_label.visible = false
	input_label.visible = false
	next_word_label.text = "Press enter for next word"
	load_words()
	
	# Reads and handles player input
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and can_type:
		# Backspace handling
		if event.keycode == KEY_BACKSPACE: # Keycode is used for modifier and action keys
			if input_label.text.length() > 0:
				input_label.text = input_label.text.left(-1)
		
		# Enter handling
		elif event.keycode == KEY_ENTER:
			# Ready to load next word
			if next_word_label.text == "Press enter for next word":
				stats_label.visible = true
				typed_stat.visible = true
				correct_stat.visible = true
				incorrect_stat.visible = true
				target_label.visible = true
				input_label.visible = true
				
				next_word_label.text = "Press enter to submit word"
				pick_random_word()
			
			# Do nothing if the user didn't type anything / prevent accidental key presses
			elif input_label.text == "":
				return
			
			# Check word spelling accuracy
			else:
				spell_check()
				
		
		# Ignore modifier keys
		elif event.unicode == 0:
			return
		
		# Typing the word
		else:
			var typed_char = char(event.unicode) # Unicode is used for character keys
			input_label.text += typed_char

# Loads words from file into an Array
func load_words():
	# Open the file
	var file = FileAccess.open("res://English1k.txt", FileAccess.READ)
	
	if file:
		# Read the whole thing as one big string
		var content = file.get_as_text()
		
		# Split the string into an array by looking for new lines
		word_list = content.split("\n", false)
		
		file.close()
		print(word_list.size(), " words")
	else:
		print("Error: Could not find the word list file.")

# Pick a random word from the list
func pick_random_word():
	input_label.modulate = Color.WHITE
	
	if word_list.size() > 0:
		# Pick a random index from the array
		var random_index = randi() % word_list.size()
		word_to_type = word_list[random_index].strip_edges() # strip_edges removes hidden spaces
		target_label.text = word_to_type
		input_label.text = ""

# Checks word accuracy
func spell_check():
	typed_words += 1
	typed_stat.text = str(typed_words)
	
	# Change word color to reflect accuracy
	if word_to_type == input_label.text:
		input_label.modulate = Color.GREEN
		correct_words += 1
		correct_stat.text = str(correct_words)
	else:
		input_label.modulate = Color.RED
		incorrect_words += 1
		incorrect_stat.text = str(incorrect_words)
	
	# Ready to load next word
	next_word_label.text = "Press enter for next word"

extends Control

# Waiting for all the child classes to load to avoid errors
@onready var target_label = $TargetWord
@onready var input_label = $InputDisplay

# Define variables
var word_list: Array = []
var word_to_type = ""
var words_typed: int = 0
var correct_words: int = 0
var incorrect_words: int = 0
var can_type: bool = true

# Runs when the game starts
func _ready():
	load_words()
	pick_random_word()
	
	# Reads and handles player input
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and can_type:
		# Backspace handling
		if event.keycode == KEY_BACKSPACE: # Keycode is used for modifier and action keys
			if input_label.text.length() > 0:
				input_label.text = input_label.text.left(-1)
		
		# Enter handling
		elif event.keycode == KEY_ENTER:
			pass
		
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
		print("Loaded ", word_list.size(), " words!")
	else:
		print("Error: Could not find the word list file.")

# Pick a random word from the list
func pick_random_word():
	if word_list.size() > 0:
		# Pick a random index from the array
		var random_index = randi() % word_list.size()
		word_to_type = word_list[random_index].strip_edges() # strip_edges removes hidden spaces
		target_label.text = word_to_type
		input_label.text = ""

# Checks word accuracy

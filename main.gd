extends Control

# Declare nodes, uses @onready to avoid 'assign nothing to someting' errors
@onready var TargetWordLabel = $TargetWord
@onready var InputTextboxLabel = $InputTextbox
@onready var InstructionsLabel = $Instructions
@onready var StatsContainer = $StatsContainer
@onready var numTypedLabel = $StatsContainer/numTyped
@onready var numCorrectLabel = $StatsContainer/numCorrect
@onready var numIncorrectLabel = $StatsContainer/numIncorrect
@onready var btnStart = $StartButton

# Declare variables
var target: String = ""
var input: String = ""
var numTyped: int = 0
var numCorrect: int = 0
var numIncorrect: int = 0
var lstWord: Array = []
var canType: bool = false
var readyForNext: bool = false

# Main function what runs when the game starts
func _ready() -> void:
	# Hide all UI execpt for the start button
	TargetWordLabel.visible = false
	InputTextboxLabel.visible = false
	InstructionsLabel.visible = false
	StatsContainer.visible = false # Visibility is an inherited state so all child labels also become invisible
	btnStart.visible = true
	
	# Game setup
	InstructionsLabel.text = "Type the word and press ENTER to submit"
	load_words()
	random_word()

# Signal up from child button node
func _on_start_button_pressed() -> void:
	# Set playing status to true so user can interact
	canType = true
	
	# Show all UI execpt for the start button
	btnStart.visible = false
	TargetWordLabel.visible = true
	InputTextboxLabel.visible = true
	InstructionsLabel.visible = true
	StatsContainer.visible = true	

# Handles user inputs
func _unhandled_input(event: InputEvent) -> void:
	# Do nothing if the input is not a down key press
	if not event is InputEventKey or not event.pressed: return # Avoids double input (1 on press 1 on release)
	
	# Handles enter key for submitting input and next word
	# Goes above canType check because user uses enter to prompt next word but shouldn't be able to type on spellcheck screen
	if event.keycode == KEY_ENTER:
		if input.length() == 0: return # Avoids accidental submissions
		
		# Next word
		if readyForNext == true:
			random_word()
			InstructionsLabel.text = "Type the word and press ENTER to submit"
			return
			
		# Submitting answer
		if input.length() > 0:
			spellcheck()
			return
	
	# Do nothing if game is loading (user not allowed to interact)
	if not canType: return
	
	# Handles backspace
	if event.keycode == KEY_BACKSPACE:
		if input.length() == 0: return
		input = input.left(-1) # Negative values removes -n characters from the back of the string
		InputTextboxLabel.text = input
	
	# Ignores non-printable characters outside ANSI keyboard keys (or similar)
	if event.unicode < 32 or event.unicode > 126: return
	
	# Handles typing and user input
	input += char(event.unicode)
	InputTextboxLabel.text = input

# Loads words from word list into array
func load_words() -> void:
	if not FileAccess.file_exists("res://WordList.txt"):
		print ("Error: WordList.txt not found")
		return
	
	var file = FileAccess.open("res://WordList.txt", FileAccess.READ)
	
	# Retuns the content of the file as a textwall with newline (\n) characters
	var fileContent = file.get_as_text()
	
	# Splits the textwall into words, removing all \n and empty spaces
	lstWord = fileContent.split("\n", false)
	file.close() # Good practice to not leave files 'hanging open'

# Picks a random word from the word array and resets input textbox
func random_word() -> void:
	# Reset flag variables
	readyForNext = false
	canType = true
	
	# Prevents error when trying to pick random from empty array
	if lstWord.is_empty(): return
	
	# Picks new word from array randomly
	target = lstWord.pick_random().strip_edges() # strip_edges() removes hidden characters and spaces (\n, tab, space, etc)
	TargetWordLabel.text = target
	
	# Resets input textbox for next word
	input = ""
	InputTextboxLabel.text = ""
	InputTextboxLabel.modulate = Color.WHITE

# Check the spelling of the user input with indicator and adjust stats
func spellcheck() -> void:
	# Disable typing while checking
	canType = false
	
	# Increment the number of words typed
	numTyped += 1
	numTypedLabel.text = str(numTyped) # Remember to cast to string because labels are strings
	
	# If word is spelled correctly
	if input.to_lower() == target: # Accepts all cases / not case-sensitive
		numCorrect += 1
		numCorrectLabel.text = str(numCorrect)
		InputTextboxLabel.modulate = Color.GREEN
	
	# Spelled incorrectly
	else:
		numIncorrect += 1
		numIncorrectLabel.text = str(numIncorrect)
		InputTextboxLabel.modulate = Color.RED
	
	# Reenable typing for user input
	InstructionsLabel.text = "Press ENTER for next word"
	readyForNext = true

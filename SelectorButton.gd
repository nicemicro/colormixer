extends Button

var my_number: int

signal button_pressed(changed_button)

func _ready():
	pass # Replace with function body.

func setMyNumber(number):
	my_number = number

func _on_SelectorButton_pressed():
	emit_signal("button_pressed", my_number)

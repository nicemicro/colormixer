extends Node2D

var selected_button: int
var buttons: Array = []
var color_previews: Array = []
var indicators: Array = []
var color_mix: Image
var fill_prev_img: Image
const PREVIEW_SIZE = 75
const MIXER_SIZE = 500
const COLOR_POINTS = [
	Vector2(0, 0),
	Vector2(0, MIXER_SIZE-1),
	Vector2(MIXER_SIZE-1, 0),
	Vector2(MIXER_SIZE-1, MIXER_SIZE-1),
	Vector2((MIXER_SIZE-1)/2, (MIXER_SIZE-1)/2)]

onready var color_selections: GridContainer = $ColorSelections
onready var color_picker: ColorPicker = $ColorPicker
onready var fill_preview: Sprite = $FillPreview
onready var color_mixer: Sprite = $ColorMixer
onready var button: PackedScene = preload("res://SelectorButton.tscn")

func _ready():
	var new_button: Button
	var new_preview: ColorRect
	var new_indicator: ColorRect
	
	selected_button = 0
	
	for index in range(5):
		new_button = button.instance()
		new_button.text = String(index)
		new_button.setMyNumber(index)
		new_button.connect("button_pressed", self, "_on_button_pressed")
		color_selections.add_child(new_button)
		buttons.append(new_button)
		new_preview = ColorRect.new()
		new_preview.color = Color.black
		new_preview.rect_min_size = Vector2(16, 16)
		color_selections.add_child(new_preview)
		color_previews.append(new_preview)
		new_indicator = ColorRect.new()
		if index == selected_button:
			new_indicator.color = Color.white
		else:
			new_indicator.color = Color.black
		new_indicator.rect_min_size = Vector2(16, 16)
		color_selections.add_child(new_indicator)
		indicators.append(new_indicator)
	color_mix = Image.new()
	color_mix.create(MIXER_SIZE, MIXER_SIZE, false, Image.FORMAT_RGBA8)
	color_mix.fill(Color.gold)
	fill_prev_img = Image.new()
	fill_prev_img.create(PREVIEW_SIZE, PREVIEW_SIZE, false, Image.FORMAT_RGBA8)
	fill_prev_img.fill(Color.gold)
	generateColorMix()
	generatePreview()

func updateTexture():
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(color_mix)
	color_mixer.texture = image_texture

func updatePreview():
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(fill_prev_img)
	fill_preview.texture = image_texture

func mixColors(x, y, maxcoord, colors):
	var rations = [0.0, 0.0, 0.0, 0.0, 0.0]
	var mixed_color: Color
	
	if x > y:
		#right of main diagonal
		if x > maxcoord - y:
			#right of minor diagonal
			rations[2] = (x - y) / 1.0 / maxcoord
			rations[3] = (x + y - maxcoord) / 1.0 / maxcoord
			rations[4] = (maxcoord - x) * 2.0  / maxcoord
		else:
			#left of minor diagonal
			rations[0] = (maxcoord -  y - x) / 1.0 / maxcoord
			rations[2] = (x - y) / 1.0 / maxcoord
			rations[4] = y * 2.0 / maxcoord
	else:
		#left of main diagonal
		if x > maxcoord - y:
			#right of minor diagonal
			rations[1] = (y - x) / 1.0 / maxcoord
			rations[3] = (x + y - maxcoord) / 1.0 / maxcoord
			rations[4] = (maxcoord - y) * 2.0  / maxcoord
		else:
			#left of minor diagonal
			rations[0] = (maxcoord - y - x) / 1.0 / maxcoord
			rations[1] = (y - x) / 1.0 / maxcoord
			rations[4] = x * 2.0 / maxcoord
	mixed_color = Color.black
	for index in range(5):
		mixed_color.r = mixed_color.r + rations[index] * colors[index].color.r
		mixed_color.g = mixed_color.g + rations[index] * colors[index].color.g
		mixed_color.b = mixed_color.b + rations[index] * colors[index].color.b
	return mixed_color

func generatePreview():
	var new_color: Color
	
	fill_prev_img.lock()
	for x in range(PREVIEW_SIZE):
		for y in range(PREVIEW_SIZE):
			new_color = mixColors(x, y, PREVIEW_SIZE-1, indicators)
			fill_prev_img.set_pixel(x, y, new_color)
	fill_prev_img.unlock()
	updatePreview()

func generateColorMix():
	var new_color: Color
	
	color_mix.lock()
	for x in range(MIXER_SIZE):
		for y in range(MIXER_SIZE):
			new_color = mixColors(x, y, MIXER_SIZE-1, color_previews)
			color_mix.set_pixel(x, y, new_color)
	color_mix.unlock()
	updateTexture()

func _on_button_pressed(number: int):
	indicators[selected_button].color = Color.black
	selected_button = number
	indicators[selected_button].color = Color.white
	generatePreview()
	color_picker.color = color_previews[selected_button].color

func _on_ColorPicker_color_changed(color):
	color_previews[selected_button].color = color

func _on_GenerateSample_pressed():
	generateColorMix()

func saveFile():
	var datetime = OS.get_datetime()
	var datestring = str(datetime.year) + "-" + str(datetime.month) + \
		"-" + str(datetime.day) + "-" + str(datetime.hour) + "-" + \
		str(datetime.minute) + "-" + str(datetime.second)
	color_mix.save_png("res://" + datestring + ".png")

func _on_SaveFile_pressed():
	saveFile()

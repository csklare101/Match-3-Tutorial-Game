extends TileMap

var board_size = 6 #how large the board is
var win = board_size * int(board_size/3)
enum Layers{hidden,revealed} #if card is hidden or revealed
var SOURCE_NUM = 6 #what tile set is loaded in
var hidden_tile_coords = Vector2(6,1) #What tile is the back face of the card
const hidden_tile_alt = 1 #What tile is the hidden one
var revealed_spots = [] #Array for what cards have been revealed
var tile_pos_to_atlas_pos = {} #Tracks where each card is in the board

var score = 0
var turns_taken = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_board()
	update_text()

func get_tiles_to_use():
	var chosen_tile_coords = []
	for i in range(board_size * int(board_size/3)): #
		var options = range(20)
		options.shuffle()
		var current = Vector2(i,0) #adds in cards from 1st row
		for j in range(3):
			chosen_tile_coords.append(current)
	print(chosen_tile_coords)
	chosen_tile_coords.shuffle()
	return chosen_tile_coords
	
func setup_board():
	var cards_to_use = get_tiles_to_use()
	for y in range(board_size):
		for x in range(board_size):
			var current_spot = Vector2(x,y)
			place_single_face_down_card(current_spot)
			var card_atlas_coords = cards_to_use.pop_back()
			tile_pos_to_atlas_pos[current_spot] = card_atlas_coords
			self.set_cell(Layers.revealed, current_spot,
			SOURCE_NUM, card_atlas_coords)

func place_single_face_down_card(coords: Vector2):
	self.set_cell(Layers.hidden, coords,
	SOURCE_NUM, hidden_tile_coords, hidden_tile_alt)
	

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			
			#local space
			var pos_clicked = Vector2(local_to_map(to_local(global_clicked)))
			print(pos_clicked)
			var current_tile_alt = get_cell_alternative_tile(Layers.hidden, pos_clicked)
			if current_tile_alt == 1 and revealed_spots.size() < 3:
				self.set_cell(Layers.hidden, pos_clicked, -1)
				revealed_spots.append(pos_clicked)
				if revealed_spots.size() == 3:
					when_three_cards_revealed()

func when_three_cards_revealed():
	#cards match
	if tile_pos_to_atlas_pos[revealed_spots[0]]	== tile_pos_to_atlas_pos[revealed_spots[1]] and tile_pos_to_atlas_pos[revealed_spots[1]] == tile_pos_to_atlas_pos[revealed_spots[2]]:
		score += 1
		revealed_spots.clear()
	else:
		put_back_cards_with_delay()
	turns_taken += 1
	update_text()

func update_text():
	$"../CanvasLayer/score_label".text = "Score: %d" % score
	$"../CanvasLayer/turns_label".text= "Turns Taken: %d" % turns_taken
	
	if score == win:
		$"../CanvasLayer/Objective".text = "YOU WIN!!!"
	
	
func put_back_cards_with_delay():
	await self.get_tree().create_timer(1.5).timeout
	for spot in revealed_spots:
		place_single_face_down_card(spot)
	revealed_spots.clear()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

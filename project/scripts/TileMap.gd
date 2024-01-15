class_name Map
extends TileMap

var main_layer: int = 0

var bread_terrain:= Vector2i(0,0)
var mold_terrain:= Vector2i(1,0)
var jam_terrain:= Vector2i(0,1)
var surrounded_mold_terrain = Vector2i(1,1)

var next_mold_tiles: PackedVector2Array
var mold_tiles_cache: PackedVector2Array

var used_cells: PackedVector2Array

@onready var spread_delay:= $MoldSpreadDelay


func _ready() -> void:
	print("ok")
	

func spread() -> void:

	used_cells = get_used_cells_by_id(main_layer, 0, mold_terrain)
	for cell in used_cells:
		get_adjacent_tiles(cell)
		
	spread_delay.start()


func get_adjacent_tiles(tile: Vector2i) -> void:
	var adjacent_tiles: PackedVector2Array = []
	var matching_tiles: PackedVector2Array = []
	adjacent_tiles = get_surrounding_cells(tile)
	
	for tile_data in adjacent_tiles:
		if get_cell_atlas_coords(main_layer,tile_data) == bread_terrain:
			matching_tiles.append(tile_data)

	#Selects a random bread tile if there is one
	if matching_tiles.size() > 0:
		var random_index: int = randi() % matching_tiles.size()
		
		var random_tile_data = matching_tiles[random_index]
		
		next_mold_tiles.append(random_tile_data)
	#if no bread tiles, appends to mold_tiles_cache
	else:
		mold_tiles_cache.append(tile)	
		
		
	for current_tile in next_mold_tiles:
		set_cell(main_layer, current_tile, 0, mold_terrain)

func _on_mold_spread_delay_timeout() -> void:
	for tile in mold_tiles_cache:
		set_cell(main_layer, tile, 0, surrounded_mold_terrain)
	next_mold_tiles.clear()
	spread()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		spread()
	
	



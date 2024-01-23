class_name Map
extends TileMap

const main_layer: int = 0

const bread_terrain := Vector2i(0,0)
const dark_bread_terrain := Vector2i(0,3)
const mold_terrain := Vector2i(1,0)
const jam_terrain := Vector2i(0,1)
const surrounded_mold_terrain := Vector2i(1,1)

const type_bread: Array[Vector2i] = [bread_terrain, dark_bread_terrain]
const type_mold: Array[Vector2i] = [mold_terrain, surrounded_mold_terrain]


## If on the spreading can be started manually via the "ui_accept" action.
@export var debug: bool = false
@export var autostart: bool = false
@export var autostart_delay: float 

var next_mold_tiles: PackedVector2Array
var mold_tiles_cache: PackedVector2Array

var used_cells: Array

@onready var spread_timer := $MoldSpreadTimer


func _ready() -> void:
	Global.tile_map = self
	
	if autostart:
		start_spread_with_delay(autostart_delay)
	
	
func start_spread_with_delay(delay: float) -> void:
	$StartDelay.start(delay)
	await $StartDelay.timeout
	start_spread()


func spread() -> void:
	used_cells = get_used_cells_by_id(main_layer, 0, mold_terrain)
	used_cells.shuffle()
	var random_index = randi_range(10, 50)
	var cells_to_change = used_cells.slice(0, random_index)
	for cell in cells_to_change:
		get_adjacent_tiles(cell)
	set_mold_cells()


func get_adjacent_tiles(tile: Vector2i) -> void:
	var adjacent_tiles: PackedVector2Array = []
	var matching_tiles: PackedVector2Array = []
	adjacent_tiles = get_surrounding_cells(tile)
	
	for tile_coords in adjacent_tiles:
		if is_type_bread(tile_coords):
			matching_tiles.append(tile_coords)

	#Selects a random bread tile if there is one
	if matching_tiles.size() > 0:
		var random_index: int = randi() % matching_tiles.size()
		
		var random_tile_data = matching_tiles[random_index]
		
		next_mold_tiles.append(random_tile_data)
	#if no bread tiles, appends to mold_tiles_cache
	else:
		mold_tiles_cache.append(tile)
		
		
func set_mold_cells() -> void:
	for current_tile in next_mold_tiles:
		place_mold(current_tile)
	next_mold_tiles.clear()


func _on_mold_spread_timer_timeout() -> void:
	for tile in mold_tiles_cache:
		set_cell(main_layer, tile, 0, surrounded_mold_terrain)
	spread()


func start_spread() -> void:
	spread_timer.start()
	

func stop_spread() -> void:
	spread_timer.stop()


#Start spread
func _input(event: InputEvent) -> void:
	if debug && Input.is_action_just_pressed("ui_home"):
		start_spread()


# Converts global coordinates to tile coordinates
func global_to_map(global_point: Vector2) -> Vector2i:
	return local_to_map(to_local(global_point))

	
# Tries to place mold at given tile_coords and then returns a boolean whether or not it successfully placed a mold or not
func place_mold(tile_coords: Vector2i) -> bool:
	if is_type_bread(tile_coords):
		set_cell(main_layer, tile_coords, 0, mold_terrain)
		return true
	return false


# Tries to place jam at given tile_coords and then returns a boolean whether or not it successfully placed a mold or not
func place_jam(tile_coords: Vector2i) -> bool:
	set_cell(main_layer, tile_coords, 0, jam_terrain)
	return true


func is_type_mold(tile_coords: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(main_layer, tile_coords)
	return atlas_coords in type_mold


func is_type_bread(tile_coords: Vector2i) -> bool:
	var atlas_coords = get_cell_atlas_coords(main_layer, tile_coords)
	return atlas_coords in type_bread


# Functions with _g suffix take in global coordinates not tile coordinates
func place_mold_g(global_coords: Vector2) -> bool:
	return place_mold(global_to_map(global_coords))


func place_jam_g(global_coords: Vector2) -> bool:
	return place_jam(global_to_map(global_coords))


func is_type_mold_g(global_coords: Vector2) -> bool:
	return is_type_mold(global_to_map(global_coords))


func is_type_bread_g(global_coords: Vector2) -> bool:
	return is_type_bread(global_to_map(global_coords))

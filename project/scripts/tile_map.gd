class_name Map
extends TileMap

const main_layer: int = 0

# The values and order of keys inside the Type enum correspond to the order in which they show up in the tilesheet
enum Type {
	BREAD = 0,
	MOLD,
	SURROUNDED_MOLD,
	JAM,
	NONE,
}

## The size that each type of tile takes up in the tile atlas
const atlas_tile_size: Vector2i = Vector2i(9, 3)

## If on the spreading can be started manually via the "ui_accept" action.
@export var debug: bool = false
@export var autostart: bool = false
@export var autostart_delay: float 

var next_mold_tiles: PackedVector2Array
var mold_tiles_cache: PackedVector2Array

var used_cells: Array

@onready var spread_timer := $MoldSpreadTimer
@onready var tile_size_scaled: Vector2i = Vector2(tile_set.tile_size) * scale


func _ready() -> void:
	Global.tile_map = self
	
	if autostart:
		start_spread_with_delay(autostart_delay)
	
	
func start_spread_with_delay(delay: float) -> void:
	$StartDelay.start(delay)
	await $StartDelay.timeout
	start_spread()


func spread() -> void:
	used_cells = get_used_cells_by_type(main_layer, Type.MOLD)
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
		if is_type_bread(main_layer, tile_coords):
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
		place_mold(main_layer, current_tile)
	next_mold_tiles.clear()


func _on_mold_spread_timer_timeout() -> void:
	for tile in mold_tiles_cache:
		set_cell_by_type(main_layer, tile, Type.SURROUNDED_MOLD)
	spread()


func get_used_cells_by_type(layer: int, type: Type) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for row in atlas_tile_size.y:
		for col in atlas_tile_size.x:
			var atlas_coords := Vector2i(col, row)
			atlas_coords.y += atlas_tile_size.y * type
			out.append_array(get_used_cells_by_id(layer, 0, atlas_coords))
	return out
	
	
func set_cell_by_type(layer: int, coords: Vector2i, type: Type) -> void:
	var atlas_coords := get_cell_atlas_coords(layer, coords)
	atlas_coords %= atlas_tile_size
	atlas_coords.y += atlas_tile_size.y * type
	set_cell(layer, coords, 0, atlas_coords)
	

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
	return local_to_map(to_local(global_point)) # TODO: Fix this to work with scaled tilemap

	
# Tries to place mold at given tile_coords and then returns a boolean whether or not it successfully placed a mold or not
func place_mold(layer: int, tile_coords: Vector2i) -> bool:
	if is_type_bread(layer, tile_coords):
		set_cell_by_type(layer, tile_coords, Type.MOLD)
		return true
	return false


# Tries to place jam at given tile_coords and then returns a boolean whether or not it successfully placed a mold or not
func place_jam(layer: int, tile_coords: Vector2i) -> bool:
	set_cell_by_type(layer, tile_coords, Type.JAM)
	return true


func is_type_mold(layer: int, tile_coords: Vector2i) -> bool:
	return get_type(layer, tile_coords) == Type.MOLD


func is_type_bread(layer: int, tile_coords: Vector2i) -> bool:
	return get_type(layer, tile_coords) == Type.BREAD


func get_type(layer: int, tile_coords: Vector2i) -> Type:
	var atlas_coords := get_cell_atlas_coords(layer, tile_coords)
	for type in Type.values():
		if atlas_coords.y < atlas_tile_size.y * (type + 1):
			return type
	return Type.NONE


# Functions with _g suffix take in global coordinates not tile coordinates
func place_mold_g(layer: int, global_coords: Vector2) -> bool:
	return place_mold(layer, global_to_map(global_coords))


func place_jam_g(layer: int, global_coords: Vector2) -> bool:
	return place_jam(layer, global_to_map(global_coords))


func is_type_mold_g(layer: int, global_coords: Vector2) -> bool:
	return is_type_mold(layer, global_to_map(global_coords))


func is_type_bread_g(layer: int, global_coords: Vector2) -> bool:
	return is_type_bread(layer, global_to_map(global_coords))

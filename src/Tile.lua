---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Tile object - - - - - - - - - - - - - - -- 
---------------------------------------------------------------------------

-- Tile objects:

--  * Has graphic symbol to represent what kind of tile this is in dungeon
--    *   " " for empty
--    *   "." for floor
--    *   "#" for wall
--    *   "<" for staircase
--    *   "%" for soil
--    *   "*" for mineral vein
--    *   "'" for open door
--    *   "+" for closed door
--  * Keeps track of room association, if not in room (default): roomId = 0

Tile = {class, roomId}
Tile.__index = Tile

Tile.EMPTY = " "
Tile.FLOOR = "."
Tile.WALL = "#"
Tile.STAIRCASE = "<"
Tile.SOIL = "%"
Tile.VEIN = "*"
Tile.C_DOOR = "+"
Tile.O_DOOR = "'"

function Tile:new(t)
  local tile = {}
  tile.class = t
  tile.roomId = 0
  
  setmetatable(tile, Tile)
  
  return tile
  
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tile:isFloor() 
  return self.class == Tile.FLOOR
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tile:isWall() 
  return (
    self.class == Tile.WALL or
    self.class == Tile.SOIL or
    self.class == Tile.VEIN
    )
end
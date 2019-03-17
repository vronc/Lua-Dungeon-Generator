-----------------------------------------------------------
-- - - - - - - - - - - - Tile object - - - - - - - - - - -- 
-----------------------------------------------------------

-- Tile objects:

--  * Has graphic symbol to represent what kind of tile this is in dungeon
--    *   " " for void
--    *   "." for floor
--    *   "#" for wall
--    *   "<" for staircase
--    *   "%" for soil
--    *   "*" for mineral vein
--  * Keeps track of room association, if not in room (default): roomId = 0

Tile = {symbol, roomId, visited}
Tile.__index = Tile

function Tile:new(c)
  local tile = {}
  tile.symbol = c
  tile.roomId = 0
  
  setmetatable(tile, Tile)
  
  return tile
  
end
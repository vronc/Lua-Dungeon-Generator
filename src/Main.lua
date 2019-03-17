require "Tiles"
require "Tile"
require "Room"

-- View example
m = Tiles:new(50,50)
m:generateRooms(15)
m:addWalls()
m:generateCorridors()
m:addWalls()
m:addStaircases()
m:printTiles()
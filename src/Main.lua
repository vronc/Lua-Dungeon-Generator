require "Tiles"
require "Tile"
require "Room"

-- View example
m = Tiles:new(50,50)
m:generateRooms(20)
m:addWalls()
m:generateCorridors()
m:addWalls()
m:addStaircases()
m:addDoors()
m:printTiles()
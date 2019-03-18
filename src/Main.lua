require "Tiles"
require "Tile"
require "Room"

--for i=1,1000 do
m = Tiles:new(50,50)
m:generateRooms(20)
m:addWalls()
m:generateCorridors()
m:addWalls()
m:addStaircases()
m:addDoors()
--end

m:printTiles()
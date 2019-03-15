require "Tiles"

-- Testing Tiles

tiles = Tiles:new(20,20)


-- ## Tests for Room ## --

-- testing addNeighbour
r1 = Room:new(1)
r2 = Room:new(2)
r1:addNeighbour(r2)
if not r1.neighbours[1] == r2 then error("AddNeighbour test failed") end
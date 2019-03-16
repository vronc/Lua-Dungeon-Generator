require "Tiles"

-- Testing Tiles

tiles = Tiles:new(20,20)

if not getDist(0,3,0,4) == 5 then error("tiles getDist test failed") end

-- ## Tests for Room ## --

-- testing addNeighbour
r1 = Room:new(1)
r2 = Room:new(2)
r1:addNeighbour(r2)
if not r1.neighbours[1] == r2 then error("AddNeighbour test failed") end

-- testing distanceTo
r1.center = {r=0,c=3}
r2.center = {r=4, c=0}
if not r1:distanceTo(r2) == 5 then error("distanceTo test failed") end

-- testing areNeighbours
r3 = Room:new(3)
if (not r1.areNeighbours(r2)) then error("areNeighbours test failed") end
if (r1.areNeighbours(r3)) then error("areNeighbours test failed") end
-- should be it's own neighbour
if (not r1.areNeighbours(r1)) then error("areNeighbours test failed") end
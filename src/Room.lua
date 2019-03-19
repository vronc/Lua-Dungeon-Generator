---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Room object - - - - - - - - - - - - - - -- 
---------------------------------------------------------------------------

-- Room is a Node-like object.

--  * Has unique id
--  * Keeps track of neighbouring rooms by keeping boolean value 
--  * at index representing neighbours' id's

Room = { id, neighbours, center, hasStaircase }
Room.__index = Room

function Room:new(id)
  local room = {}
  room.id = id
  room.neighbours = {}
  room.center = {r, c}
  room.hasStaircase = false
  
  setmetatable(room, Room)
  
  return room
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:addNeighbour(other)
  self.neighbours[other.id]=true
end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:hasNeighbours()
  return tablelength(self.neighbours)>1
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:areNeighbours(other)
  return (self.neighbours[other.id])

end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:distanceTo(other)
  -- returns distance from self to other room's center.
  
  return math.sqrt(
    math.pow(math.abs(self.center.r-other.center.r),2)+
    math.pow(math.abs(self.center.c-other.center.c),2)
    )
end
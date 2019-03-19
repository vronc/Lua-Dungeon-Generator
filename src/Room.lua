local pow = math.pow

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
  local room = {
    id=id,
    neighbours = {},
    center = {},
    hasStaircase = false
    }
  
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
    pow(math.abs(self.center[1]-other.center[1]),2)+
    pow(math.abs(self.center[2]-other.center[2]),2)
    )
end
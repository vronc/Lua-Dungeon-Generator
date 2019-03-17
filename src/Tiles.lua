seed = os.time()
--seed=1552787852
math.randomseed(seed)
print("seed: "..seed)

-----------------------------------------------------------
-- - - - - - - - - - - Tiles object - - - - - - - - - - - - 
-----------------------------------------------------------

-- A Tiles object keep an overview of the Tile objects which are kept in a matrix

Tiles = {height, width, matrix}
Tiles.__index = Tiles

function Tiles:new(height, width)
  if height < 10 or width < 10 then error("Tiles must have height>=10, width>=10") end
  local tiles = {}
  tiles.height = height
  tiles.width = width
  tiles.matrix ={}
  
  -- Will hold all rooms, index is ID 
  tiles.rooms = {}
  
  setmetatable(tiles, Tiles)

  tiles:initMap(height, width)
  return tiles
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:initMap(height, width)

  self.matrix[0] = {}
  wallTile = Tile:new("#")
  wallTile.visited = true
  
  -- Create upper and lower bound walls
  for j=0,width+1 do
    self.matrix[0][j] = wallTile
  end
  self.matrix[height+1] = {}
  for j=0,width+1 do
    self.matrix[height+1][j] = wallTile
  end
  
  -- Create left and right bound walls
  for i=1,height do
    self.matrix[i] = {}     -- create a new row
    self.matrix[i][0] = wallTile
    for j=1,width do
      self.matrix[i][j] = Tile:new(" ")
    end
    self.matrix[i][width+1] = wallTile
  end
end 

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:printTiles ()

    for i=0,self.height+1 do
      local row=""
      for j=0,self.width+1 do
        row=row..self.matrix[i][j].symbol.." "
        --row=row..self.matrix[i][j].roomId.." "    -- for exposing room-ids
      end
      print(row)
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:getRandRoom()
  -- return: Random room
  local i = math.random(1,#self.rooms)
  return self.rooms[i]
end


-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:getTile(r, c)
  return self.matrix[r][c]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:isRoom(i,j)
  return (not (self:getTile(i,j).roomId == 0))
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
  function Tiles:generateRooms(amount)
    for i = 1,amount do
      self:generateRoom()
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:generateRoom()
  -- Will randomly place rooms across tiles (no overlapping)
  minRoomSize = 3
  maxRoomSize = 15
  startRow = math.random(1, self.height-maxRoomSize)
  startCol = math.random(1, self.width-maxRoomSize)
  
  height = math.random(minRoomSize, maxRoomSize)
  width = math.random(minRoomSize, maxRoomSize)
  
  ok = true
  for i=startRow-1, startRow+height+1 do
    for j=startCol-1, startCol+width+1 do
      
      if (self:isRoom(i,j)) then
        -- Room is overlapping other room, room is discarded
        return
      end
    end
  end
  self:buildRoom(startRow, startCol, startRow+height, startCol+width)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:buildRoom(startR, startC, endR, endC)
  -- paint room onto board 
  
    id = #self.rooms+1
    room = Room:new(id)
    room:addNeighbour(id)    -- is it's own neighbour
    
    r=endR-math.floor((endR-startR)/2)
    c=endC-math.floor((endC-startC)/2)
    room.center = {r=r, c=c}
    table.insert(self.rooms, room)
    for i=startR, endR do
      for j=startC, endC do
        tile = self:getTile(i,j)
        tile.roomId = id
        tile.symbol = "."      -- floor tile
      end
    end
    
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:generateCorridors()
  if #self.rooms < 1 then error("Can't generate corridors, no rooms exists")
  elseif #self.rooms == 1 then return end
  
  -- Choosing root room
  room = self:getRandRoom()
  roomId = room.id
  
  -- ### KRUSKALS (ish) ### --
  
  visited = {}
  unvisited = table.clone(self.rooms)
  unvisited[roomId]=false
  visited[roomId] = true
  repeat
    dist = 1e309    -- ~inf
    
    -- Choosing unvisited room
    i = 0
    repeat
      i=i+1
      unvRoom = unvisited[i]
    until (unvRoom)

    -- Determining if choosen room is closer than previous choice
    if (room:distanceTo(unvRoom) < dist) then
      nextRoom = unvRoom
      dist = room:distanceTo(nextRoom)
      room:addNeighbour(nextRoom.id)
      nextRoom:addNeighbour(room.id)
      self:buildCorridor(room, nextRoom)
      visited[nextRoom.id]=true
      unvisited[i]=false
      room=nextRoom
    end

  until tablelength(visited) == #self.rooms
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:buildCorridor(sRoom, eRoom)
  local row = sRoom.center.r
  local col = sRoom.center.c
  local erow = eRoom.center.r
  local ecol = eRoom.center.c
  
  dist = getDist(row, col, erow, ecol)
  repeat
    self:getTile(row, col).symbol = "."

    if getDist(row+1, col, erow, ecol) < dist then
      row = row+1
      dist = getDist(row, col, erow, ecol)
    elseif getDist(row-1, col, erow, ecol) < dist then
      row = row-1
      dist = getDist(row, col, erow, ecol)
    elseif getDist(row, col+1, erow, ecol) < dist then
      col=col+1
      dist = getDist(row, col, erow, ecol)
    elseif getDist(row, col-1, erow, ecol) < dist then
      col=col-1
      dist = getDist(row, col, erow, ecol)
    end
  until (dist <= 0)
  
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tiles:addWalls()
  -- add walls around generated rooms/corridors
  
  veinSpawnRate = 0.02
  soilSpawnRate = 0.1
  for i=1,self.height do
    for j=1,self.width do
      if not(self:getTile(i,j).symbol==".") and
            (self:getTile(i+1,j).symbol=="." or
             self:getTile(i-1,j).symbol=="." or
             self:getTile(i,j+1).symbol=="." or
             self:getTile(i,j-1).symbol=="." or
             self:getTile(i-1,j-1).symbol=="." or
             self:getTile(i+1,j+1).symbol=="." or
             self:getTile(i-1,j+1).symbol=="." or 
             self:getTile(i+1,j-1).symbol==".") then
        
        if math.random() <= veinSpawnRate then
          self:getTile(i,j).symbol="*"
          
        elseif math.random() <= soilSpawnRate then
          self:getTile(i,j).symbol="%"
          soilspawnRate = 0.7
        else
          self:getTile(i,j).symbol="#"
          soilSpawnRate = 0.1
        end
      end
    end
  end
end  

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:decorateRooms()
  -- add staircases etc
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-----------------------------------------------------------
-- - - - - - - - - - - - Tile object - - - - - - - - - - -- 
-----------------------------------------------------------

-- Tile objects have a symbol (wall, entrance, floor, stairway...)
-- Unaware of placement in tiles matrix
-- visited attribute used when carving corridors

Tile = {symbol, roomId, visited}
Tile.__index = Tile

function Tile:new(c)
  local tile = {}
  tile.symbol = c
  tile.roomId = 0
  tile.visited = false
  
  setmetatable(tile, Tile)
  
  return tile
  
end

-----------------------------------------------------------
-- - - - - - - - - - - - Room object - - - - - - - - - - -- 
-----------------------------------------------------------

-- Room is a Node-like object.

--  * Has unique id
--  * Keeps track of neighbouring rooms.

Room = { id, neighbours, center }
Room.__index = Room

function Room:new(id)
  local room = {}
  room.id = id
  room.neighbours = {}
  room.center = {r, c}
  
  setmetatable(room, Room)
  
  return room
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:addNeighbour(n)
  self.neighbours[n]=true
end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:hasNeighbours()
  return tablelength(self.neighbours)>1
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:distanceTo(other)
  return math.sqrt(
    math.pow(math.abs(self.center.r-other.center.r),2)+
    math.pow(math.abs(self.center.c-other.center.c),2)
    )
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:areNeighbours(other)
  return (self.neighbours[other.id])
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 


-----------------------------------------------------------
-- - - - - - - - - - - Global functions - - - - - - - - - -
-----------------------------------------------------------


-- source: https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-- source: http://lua-users.org/wiki/CopyTable
function table.clone(org)
  return {table.unpack(org)}
end

function getDist(row1, col1, row2, col2)
  return math.sqrt(
    math.pow(math.abs(row1-row2),2)+
    math.pow(math.abs(col1-col2),2)
    )
end  

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

-- View example
m = Tiles:new(50,50)
m:generateRooms(15)
m:generateCorridors()
m:addWalls()
m:printTiles()
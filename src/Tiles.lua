require "Queue"

seed = os.time()
--seed = 1552689734
--seed=1552676386
--seed=1552692988     --gets stuck
--seed = 1552693161
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

  tiles.matrix[0] = {}
  wallTile = Tile:new("#")
  wallTile.visited = true
  
  -- Create upper and lower bound walls
  for j=0,width+1 do
    tiles.matrix[0][j] = wallTile
  end
  tiles.matrix[height+1] = {}
  for j=0,width+1 do
    tiles.matrix[height+1][j] = wallTile
  end
  
  -- Create left and right bound walls
  for i=1,height do
    tiles.matrix[i] = {}     -- create a new row
    tiles.matrix[i][0] = wallTile
    for j=1,width do
      tiles.matrix[i][j] = Tile:new(" ")
    end
    tiles.matrix[i][width+1] = wallTile
  end
  return tiles
end

  -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:getTile(r, c)
  return self.matrix[r][c]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:printTiles ()

    for i=0,self.height+1 do
      row=""
      for j=0,self.width+1 do
        row=row..self.matrix[i][j].class.." "
        --row=row..self.matrix[i][j].roomId.." "    -- for exposing room-ids
      end
      print(row)
    end
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
  maxRoomSize = 10 
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

function Tiles:isRoom(i,j)
  return (not (self:getTile(i,j).roomId == 0))
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:buildRoom(startR, startC, endR, endC)
  -- paint room onto board 
    id = #self.rooms+1
    table.insert(self.rooms, Room:new(id))
    for i=startR, endR do
      for j=startC, endC do
        tile = self:getTile(i,j)
        tile.roomId = id
        tile.class = "."      -- floor tile
      end
    end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:generateCorridors()
  if #self.rooms < 1 then error("Can't generate corridors, no rooms exists")
  elseif #self.rooms == 1 then return end
  
  -- Choosing root room
  repeat
    row = math.random(1,self.height)
    col = math.random(1,self.width)
  until self:isRoom(row, col)
 
 corridors = 0
  repeat
    endRow, endCol = self:generateCorridor(row, col)
    if endRow == "deadEnd" then break end
    row = endRow
    col = endCol
    corridors = corridors +1
  
  until corridors == 10
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:generateCorridor(row, col)
  -- Input: coordinates for corridor's start
  -- Output: coordinated for corridor's end

  q = Queue:new()
  startId = self:getTile(row,col).roomId
  start={row,col}
  repeat
    tile = self:getTile(row,col)
    self:getTile(row, col).visited = true
    tile.class = "."
    unvisitedNeigh = self:getUnvisitedNeigh(row, col)
    
    if #unvisitedNeigh > 0 then
      n = math.random(1,#unvisitedNeigh)
      neigh = unvisitedNeigh[n]
      Queue.pushleft(q, neigh)
      row = neigh[1]
      col = neigh[2]
    else
      tile.class = " "

      repeat
        backTrack = Queue.popleft(q)
        if backTrack == "end" then return "deadEnd" end
        row = backTrack[1]
        col = backTrack[2]
        -- not stable:
      until true == false
    end
    roomId = self:getTile(row,col).roomId
    isStartRoom = (roomId == startId)
  until (self:isRoom(row, col) and not isStartRoom)
  
  print(roomId, startId)
  self.rooms[roomId]:addNeighbour(startId)
  self.rooms[startId]:addNeighbour(roomId)
  return row, col
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:getUnvisitedNeigh(row, col)
  
  unvisited = {}
  step = {-1,1}
  for i = 1,2 do

    if not self:getTile(row+step[i], col).visited then 
      table.insert(unvisited, {row+step[i], col})
    end
    if not self:getTile(row, col+step[i]).visited then 
      table.insert(unvisited, {row, col+step[i]})
    end
  end
  return unvisited
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:isConnected()
  for i=1,#self.rooms do
    allConnected = true
    if #self.rooms[i].neighbours < 1 then
      allConnected = false
      break
    end
  end
  return allConnected
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
-----------------------------------------------------------
-- - - - - - - - - - - - Tile object - - - - - - - - - - -- 
-----------------------------------------------------------

-- Tile objects have a class (wall, entrance, floor, stairway...)
-- Unaware of placement in tiles matrix
-- visited attribute used when carving corridors

Tile = {class, roomId, visited}
Tile.__index = Tile

function Tile:new(c)
  local tile = {}
  tile.class = c
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

Room = { id, neighbours }
Room.__index = Room

function Room:new(id)
  local room = {}
  room.id = id
  room.neighbours = {}
  
  setmetatable(room, Room)
  
  return room
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Room:addNeighbour(n)
  table.insert(self.neighbours, n)
end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 


-- View example
m = Tiles:new(40,40)
m:generateRooms(10)
allConnected = false

repeat
  m:generateCorridors()
  m:printTiles()
until m:isConnected()
m:printTiles()
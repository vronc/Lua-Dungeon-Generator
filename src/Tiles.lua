--seed = os.time()
seed = 1552665750
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

  -- Create upper and lower bound walls
  tiles.matrix[0] = {}
  wallTile = Tile:new("#")
  for j=0,width+1 do
    tiles.matrix[0][j] = wallTile
  end
  tiles.matrix[height+1] = {}
  for j=0,width+1 do
    tiles.matrix[height+1][j] = wallTile
  end
  
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
        -- row=row..self.matrix[i][j].ids.." "    -- for exposing room-ids
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
    row = endRow
    col = endCol
    corridors = corridors +1
    
    -- to be changed, row is nil as the corridor has hit a wall
    -- need to implement backtracking in generateCorridor
  until corridors == 5 or row==nil
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:generateCorridor(row, col)
  -- Input: coordinates for corridor's start
  -- Output: coordinated for corridor's end
  
  
  -- TO BE DONE: implement backtracking
  
  print(row,col)
  startTile = self:getTile(row,col)
  
  repeat
    dice = math.random(1,4)
    if dice == 1 then row = row +1
    elseif dice == 2 then row = row -1
    elseif dice == 3 then col = col +1
    elseif dice == 4 then col = col -1 end
    self:getTile(row, col).class = "."

    if (row>self.height or row<1 or col>self.width or col<1) then print("breaking") return end
    isStartRoom = (self:getTile(row,col).roomId == startTile.roomId)
  until (self:isRoom(row, col) and not isStartRoom)
  return row, col
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
m:generateCorridors()
m:printTiles()
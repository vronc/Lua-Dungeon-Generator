local FuncModule = require("helpFunctions")
local TileModule = require("Tile")
local RoomModule = require("Room")

local random = math.random
local floor = math.floor
local ceil = math.ceil

seed = os.time()
math.randomseed(seed)
print("seed: "..seed)

---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Level object - - - - - - - - - - - - - - - 
---------------------------------------------------------------------------

-- A Level object consist of several Tile objects which together make up 
-- one dungeon level.

Level = {height, width, matrix, rooms, entrances, staircases}
Level.__index = Level

Level.M_ROOMS = 25
Level.M_ROOM_SIZE = 10

Level.veinSpawnRate = 0.02
Level.soilSpawnRate = 0.05

function Level:new(height, width)
  if height < 10 or width < 10 then error("Level must have height>=10, width>=10") end
  local level = { height=height,
                width=width,
                matrix={},
                rooms = {},
                entrances = {},
                staircases = {},
                rootRoom=nil,
                endRoom=nil,
                nr=nr
                }
  
  setmetatable(level, Level)
  return level
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:generateLevel()
  
  self:initMap(self.height, self.width)
  self:generateRooms()
  self:generateCorridors()
  self:addStaircases()
  self:addDoors()
  self:placeBoss()
  self:placePlayer()
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:initMap(height, width)

  -- Create void
  for i=-1,height+1 do
    self.matrix[i] = {}
    for j=0,width+1 do
      self.matrix[i][j] = Tile:new(Tile.EMPTY)
    end
  end
  
  self:addWalls(0, 0, height+1, width+1)
end 

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:printLevel ()
  local s = "L E V E L  "..self.nr
  local space=""
  for i=1, floor((self.width+2)/2-(string.len(s))/4) do
    space = space.."  "
  end
  print(space..s..space)
  
  for i=1,string.len(s) do
    
  end

    for i=0,self.height+1 do
      local row=""
      for j=0,self.width+1 do
        row=row..self.matrix[i][j].class..Tile.EMPTY
        --row=row..self.matrix[i][j].roomId..Tile.EMPTY    -- for exposing room-ids
      end
      print(row)
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:setLevelNr(nr)
  self.nr = nr
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getRandRoom()
  -- return: Random room in level
  local i = random(1,#self.rooms)
  return self.rooms[i]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getRoot()
  -- return: Room that is root of room tree if such has been generated.
  return self.rootRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getEnd()
  -- return: Leaf room added last to tree if such has been generated.
  return self.endRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getStaircases()
  -- To retrieve individual staircase, index [1] for row, [2] for col on individual entry.
  return self.staircases
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:getTile(r, c)
  return self.matrix[r][c]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:isRoom(row,col)
  return (not (self:getTile(row,col).roomId == 0))
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getAdjacentTiles(row, col)
  -- returns table containing all adjacent tiles to given position.
  -- Including self!
  
  local result={}
  local adj=getAdjacentPos(row,col)
  for i=1,#adj do
    local row, col = adj[i].r, adj[i].c
    result[#result+1] = self:getTile(row, col)
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
  function Level:generateRooms()
    for i = 1,Level.M_ROOMS do
      self:generateRoom()
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:generateRoom()
  -- Will randomly place rooms across tiles (no overlapping)
  local minRoomSize = 3
  local startRow = random(1, self.height-Level.M_ROOM_SIZE)
  local startCol = random(1, self.width-Level.M_ROOM_SIZE)
  
  local height = random(minRoomSize, Level.M_ROOM_SIZE)
  local width = random(minRoomSize, Level.M_ROOM_SIZE)

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

function Level:buildRoom(startR, startC, endR, endC)
  -- paint room onto board 

  local id = #self.rooms+1
  local room = Room:new(id)
  
  local r,c =endR-floor((endR-startR)/2), endC-floor((endC-startC)/2)
  room.center = {r, c}
  self.rooms[#self.rooms+1] = room
  for i=startR, endR do
    for j=startC, endC do
      local tile = self:getTile(i,j)
      tile.roomId, tile.class = id, Tile.FLOOR    -- floor tile
    end
  end
  self:addWalls(startR-1, startC-1, endR+1, endC+1)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:generateCorridors()
  if #self.rooms < 1 then error("Can't generate corridors, no rooms exists")
  elseif #self.rooms == 1 then return end

  q = prims(table.clone(self.rooms))
  neighbours = Queue.popleft(q)
  self.rootRoom = neighbours[1]
  repeat
    self:buildCorridor(neighbours[1], neighbours[2])
    self.endRoom=neighbours[2]
    neighbours = Queue.popleft(q)
  until neighbours == "end"
  
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:buildCorridor(sRoom, eRoom)
  local srow, scol = sRoom.center[1], sRoom.center[2]
  local erow, ecol = eRoom.center[1], eRoom.center[2]
  dist = getDist(srow, scol, erow, ecol)
  
  repeat
    row, col = srow, scol
    local adj = getAdjacentPos(srow, scol)

    for i=1,#adj do
      local adjr, adjc = adj[i].r, adj[i].c
      if (getDist(adjr, adjc, erow, ecol) < dist) and
          i%2==0        -- not picking diagonals
      then
        srow, scol = adjr, adjc
        dist = getDist(srow, scol, erow, ecol)
        --break           -- comment for more diagonal (shorter) walks!
      end
      self:buildCorridorTile(row, col, adj)
      if random() < 0.1 then self:randomBlob(row,col,adj) end
    end
  until (self:getTile(srow, scol).roomId == eRoom.id)
  
  if self:isValidEntrance(row, col) then 
    self.entrances[#self.entrances+1] = self:getTile(row,col)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:buildCorridorTile(r, c, adj)
  -- Builds floor tile surrounded by walls. 
  -- Adjacent floor tiles remain floor tiles.

  self:getTile(r, c).class = Tile.FLOOR
  for i=1,#adj do
    adjR, adjC = adj[i].r, adj[i].c
    if not (self:getTile(adjR, adjC).class == Tile.FLOOR) then 
      self:placeWall(adjR, adjC)
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:isValidEntrance(row, col)
  -- Tile is a valid entrance position if there is a wall above and below it or
  -- to the left and to the right of it.
  
  return (
    (self:getTile(row+1,col):isWall() and self:getTile(row-1,col):isWall()) or
    (self:getTile(row,col+1):isWall() and self:getTile(row,col-1):isWall())
    )
end
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addDoors()
  -- Adds open or closed door randomly to entrance tiles
  
  for i=1,#self.entrances do
    if random() > 0.5 then
      self.entrances[i].class = Tile.C_DOOR
    else
      self.entrances[i].class = Tile.O_DOOR
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addWalls(startR, startC, endR, endC)
  -- Places walls on circumference of given rectangle.
  
  -- Upper and lower sides
  for j=startC,endC do
    self:placeWall(startR, j)
    self:placeWall(endR, j)
  end
  
  -- Left and right sides
  for i=startR,endR do
    self:placeWall(i, startC)
    self:placeWall(i, endC)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:placeWall(r,c)
  -- Places wall at given coordinate. Could either place
  -- regular wall, soil or mineral vein
  
  local tile = self:getTile(r,c)
  
  if random() <= Level.veinSpawnRate then
    tile.class = Tile.VEIN
  elseif random() <= Level.soilSpawnRate then
    tile.class = Tile.SOIL
    Level.soilSpawnRate = 0.6     -- for clustering
  else
    tile.class = Tile.WALL
    Level.soilSpawnRate = 0.05
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:addStaircases()
  -- Number of staircases depend on number of rooms
  
  local maxStaircases = ceil(#self.rooms-(#self.rooms/2))
  local staircases = random(2,maxStaircases)

  repeat
    local room = self:getRandRoom()
    if not room.hasStaircase then
      self:placeStaircase(room)
      staircases = staircases-1
    end 
  until staircases==0
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:placeStaircase(room)
  -- Places staircase in given room. 
  -- Position is random number of steps away from center.
  local steps = random(0, floor(Level.M_ROOM_SIZE/2))
  
  local nrow, ncol = room.center[1], room.center[2]
  repeat 
    row, col = nrow, ncol
    nrow, ncol = getRandNeighbour(row, col)
  until self:getTile(nrow, ncol).roomId ~= room.id or steps == 0

  self:getTile(row, col).class=Tile.STAIRCASE
  room.hasStaircase = true
  table.insert( self.staircases, { row, col } )
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:placeBoss() 
  local endr, endc =self:getEnd().center[1], self:getEnd().center[2]
  self:getTile(endr,endc).class=Tile.BOSS
end
  
function Level:placePlayer()
  local rootr, rootc = self:getRoot().center[1], self:getRoot().center[2]
  self:getTile(rootr,rootc).class=Tile.PLAYER
end

function Level:randomBlob(r,c,adj)
  for i=1,10 do
    local r,c = getRandNeighbour(r,c)
    local adj = getAdjacentPos(r, c)
    if (self:getTile(r,c).roomId==0) then
      self:buildCorridorTile(r, c, adj)
    end
  end
end
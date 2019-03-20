require "helpFunctions"
require "Tile"
require "Room"
--seed = os.time()
local random = math.random
local floor = math.floor
local ceil = math.ceil

---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Level object - - - - - - - - - - - - - - - 
---------------------------------------------------------------------------

-- A Level object consist of several Tile objects which together make up 
-- one dungeon level.

Level = {height, width, matrix, rooms, entrances, staircases}
Level.__index = Level

function Level:new(height, width)
  if height < 10 or width < 10 then error("Level must have height>=10, width>=10") end
  local level = { height=height, 
                width=width, 
                matrix={}, 
                maxRoomSize = 15,
                maxRooms = 15,
                rooms = {},
                entrances = {},
                staircases = {},
                rootRoom=nil, 
                endRoom=nil,
                veinSpawnRate = 0.02,
                soilSpawnRate = 0.05
                }
  
  setmetatable(level, Level)
  level:generateLevel()
  
  return level
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:generateLevel()
  
  self:initMap(self.height, self.width)
  self:generateRooms()
  self:generateCorridors()
  self:addStaircases()
  self:addDoors()
  if not self:getRoot() then print(seed) end
  local rootr, rootc = self:getRoot().center[1], self:getRoot().center[2]
  local endr, endc =self:getEnd().center[1], self:getEnd().center[2]
  self:getTile(rootr,rootc).class="@"
  self:getTile(endr,endc).class="B"
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

    for i=-1,self.height+1 do
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
  local s = "  LEVEL  "..nr.."  "
  local start = floor(self.width/2-string.len(s)/2)

  for i=1,string.len(s) do
    --print(s[i])
    --print(self:getTile(0,start+i).class)
    self:getTile(-1,start+i).class = s[i]
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getRandRoom()
  -- return: Random room
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
  -- To retrieve individual staircase, call .r for row, .c for col on individual entry.
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

function Level:getAdjacentPos(row, col)
  -- returns table containing all adjacent positions {r,c} to given position
  -- INCLUDING SELF. to change this:
  -- add if (not (dx == 0 and dy == 0)) then ... end
  
  local result = {}
  for dx =-1,1 do
    for dy=-1,1 do 
      result[#result+1]={ row+dy, col+dx }
    end  
  end
  for i=1,#result do
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:getAdjacentTiles(row, col)
  -- returns table containing all adjacent tiles to given position.
  -- Including self!
  
  local result={}
  local adj=self:getAdjacentPos(row,col)
  for i=1,#adj do
    local row = adj[i][1]
    local col = adj[i][2]
    result[#result+1] = self:getTile(row, col)
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
  function Level:generateRooms()
    for i = 1,self.maxRooms do
      self:generateRoom()
    end
  end
  
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:generateRoom()
  -- Will randomly place rooms across tiles (no overlapping)
  local minRoomSize = 3
  local startRow = random(1, self.height-self.maxRoomSize)
  local startCol = random(1, self.width-self.maxRoomSize)
  
  local height = random(minRoomSize, self.maxRoomSize)
  local width = random(minRoomSize, self.maxRoomSize)

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
  room:addNeighbour(room)    -- rooms are their own neighbours
  
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
  
  -- ### PRIM'S ALGORITHM ### --

  local visited={}
  local unvisited = table.clone(self.rooms)
  
  local root=table.remove(unvisited, 1)
  self.rootRoom=root
  visited[#visited+1] = root
  repeat
    local dist = 1e309    -- ~inf
    for i=1,#visited do
      for j=1,#unvisited do

        if (unvisited[j]:distanceTo(visited[i]) < dist) then
          dist = unvisited[j]:distanceTo(visited[i])
          startRoom=visited[i]
          endIndex=j
        end
      end
    end
    endRoom = table.remove(unvisited, endIndex)
    self:buildCorridor(startRoom, endRoom)
    visited[#visited+1] = endRoom

  until #visited == #self.rooms
  self.endRoom=endRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Level:buildCorridor(sRoom, eRoom)
  local srow, scol = sRoom.center[1], sRoom.center[2]
  local erow, ecol = eRoom.center[1], eRoom.center[2]
  dist = getDist(srow, scol, erow, ecol)
  
  repeat
    row, col = srow, scol
    local adj = self:getAdjacentPos(srow, scol)

    for i=1,#adj do
      local adjr, adjc = adj[i][1], adj[i][2]
      if (getDist(adjr, adjc, erow, ecol) < dist) and
          i%2==0        -- not picking diagonals
      then
        srow, scol = adjr, adjc
        dist = getDist(srow, scol, erow, ecol)
        --break           -- comment for more diagonal (shorter) walks!
      end
      self:buildCorridorTile(row, col, adj)
    end
  until (self:getTile(srow, scol).roomId == eRoom.id)
  
  if self:isValidEntrance(row, col) then 
    self.entrances[#self.entrances+1] = self:getTile(row,col)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:buildCorridorTile(row, col, adj)
  -- Builds floor tile surrounded by walls. 
  -- Adjacent floor tiles remain floor tiles.
  
  self:getTile(row, col).class = Tile.FLOOR
  for i=1,#adj do
    adjR = adj[i][1]
    adjC = adj[i][2]
    if not (self:getTile(adjR, adjC):isFloor()) then 
      self:placeWall(adjR, adjC)
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:isValidEntrance(row, col)
  -- Tile is a valid entrance position if there is a wall above/below it or
  -- to the left/to the right of it.
  
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

  -- Create upper and lower bound walls
  for j=startC,endC do
    self:placeWall(startR, j)
    self:placeWall(endR, j)
  end
  
  -- Create left and right bound walls
  for i=startR,endR do
    self:placeWall(i, startC)
    self:placeWall(i, endC)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:placeWall(r,c)
  -- Places wall at given coordinate. Could either place
  -- wall, soil or mineral vein
  
  local tile = self:getTile(r,c)
  
  if random() <= self.veinSpawnRate then
    tile.class = Tile.VEIN
  elseif random() <= self.soilSpawnRate then
    tile.class = Tile.SOIL
    self.soilSpawnRate = 0.6     -- for clustering
    else
    tile.class = Tile.WALL
    self.soilSpawnRate = 0.05
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Level:addStaircases()
  -- Adds staircases randomly
  -- Number of staircases depend on number of rooms
  
  local maxStaircases = ceil(#self.rooms-(#self.rooms/2))
  local staircases = random(1,maxStaircases)

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
  
  room.hasStaircase = true
  local dir={ random(-1,1), random(-1,1) }
  local steps = random(0, floor(self.maxRoomSize/2))
  local row, col = room.center[1], room.center[2]
  
  for i=1,steps do
    local nrow, ncol = row+dir[1], col+dir[2]
    if not (self:getTile(nrow, ncol).roomId == room.id) then
      break
    else
      local row, col = nrow, ncol
    end
  end
  self:getTile(row, col).class=Tile.STAIRCASE
  self.staircases[#self.staircases+1] = { row, col }
end
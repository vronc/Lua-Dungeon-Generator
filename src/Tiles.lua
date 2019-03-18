require "helpFunctions"
require "Tile"
require "Room"
require "Queue"

seed = os.time()
--seed=1552867281
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
  -- Will hold tiles registered as room entrances
  tiles.entrances = {}
  
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
    room:addNeighbour(room)    -- rooms are their own neighbours
    
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
  
  -- ### PRIM'S ALGORITHM ### --

  local visited={}
  local unvisited = table.clone(self.rooms)
  
  local root=table.remove(unvisited, 1)
  table.insert(visited, root)
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
    table.insert(visited, endRoom)

  until #visited == #self.rooms
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
  
function Tiles:buildCorridor(sRoom, eRoom)
  local srow = sRoom.center.r
  local scol = sRoom.center.c
  local erow = eRoom.center.r
  local ecol = eRoom.center.c
  
  dist = getDist(srow, scol, erow, ecol)
  
  repeat
    row = srow
    col = scol
    self:getTile(row, col).symbol = "."
    adj = self:getAdjacentPos(srow, scol)

    for i=1,#adj do
      srow = adj[i].r
      scol = adj[i].c
      if (getDist(srow, scol, erow, ecol) < dist) and 
          i%2==0        -- not picking diagonals
      then
        dist = getDist(srow, scol, erow, ecol)
        break           -- remove for more diagonal (shorter) walks!
      end
    end
  until (self:getTile(srow, scol).roomId == eRoom.id)
  
  if self:isValidEntrance(row, col) then 
    table.insert(self.entrances, self:getTile(row,col)) 
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tiles:isValidEntrance(row, col)
  return (
    self:getTile(row+1,col):isWall() and self:getTile(row-1,col):isWall() or
    self:getTile(row,col+1):isWall() and self:getTile(row,col-1):isWall()
    )
end
-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tiles:addDoors()
  -- Adds open or closed door randomly to entrance tiles
  
  for i=1,#self.entrances do
    if math.random() > 0.5 then
      self.entrances[i].symbol = "+"
    else
      self.entrances[i].symbol = "'"
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tiles:addWalls()
  -- add walls around generated rooms/corridors
  -- Places wall at given coordinate. Could either place
  -- wall "#", soil "%" or mineral vein "*"

  veinSpawnRate = 0.02
  soilSpawnRate = 0.1
  
  for i=1,self.height do
    for j=1,self.width do

      local adj=self:getAdjacentTiles(i,j)
      for k=1,#adj do
        if adj[k].symbol == "." and 
           not(self:getTile(i,j).symbol==".") then
          
          tile = self:getTile(i,j)

          if math.random() <= veinSpawnRate then
            tile.symbol="*"
            elseif math.random() <= soilSpawnRate then
            tile.symbol="%"
            soilspawnRate = 0.7     -- for clustering
            else
            tile.symbol="#"
            soilSpawnRate = 0.1
          end
          break
        end
      end

    end
  end
end  

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:getAdjacentPos(row, col)
  -- returns table containing all adjacent positions {r,c} to given position
  -- INCLUDING SELF. to change this:
  -- add if (not (dx == 0 and dy == 0)) then ... end
  
  local result = {}
  for dx =-1,1 do
    for dy=-1,1 do 
      table.insert(result, {r=row+dy, c=col+dx})
    end  
  end
  for i=1,#result do
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:getAdjacentTiles(row, col)
  -- returns table containing all adjacent tiles to given position.
  
  local result={}
  local adj=self:getAdjacentPos(row,col)
  for i=1,#adj do
    row = adj[i].r
    col = adj[i].c
    table.insert(result, self:getTile(row, col))
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:addStaircases()
  -- Adds staircases randomly
  
  local maxStaircases = math.ceil(#self.rooms-(#self.rooms/2))
  staircases = math.random(1,maxStaircases)

  repeat
    local room = self:getRandRoom()
    if not room.hasStaircase then
      self:placeStaircase(room)
      staircases = staircases-1
    end 
  until staircases==0
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 

function Tiles:placeStaircase(room)
  room.hasStaircase = true
  dir={ r=math.random(-1,1), c=math.random(-1,1) }
  steps = math.random(0,7)
  row = room.center.r
  col = room.center.c
  
  for i=1,steps do
    nrow=row+dir.r
    ncol=col+dir.c
    if not (self:getTile(nrow, ncol).roomId == room.id) then
      break
    else
      row=nrow
      col=ncol
    end
  end
  self:getTile(row, col).symbol="<"
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- 
function Tiles:generateCorridor(row, col)
  -- Input: coordinates for corridor's start
  -- Output: coordinates for corridor's end

  q = Queue:new()
  startId = self:getTile(row,col).roomId
  start={row,col}
  
  repeat
    tile = self:getTile(row,col)
    tile.visited = true
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
        self:getTile(row,col).visited=true
      until #self:getUnvisitedNeigh(row, col)>0
    end
    roomId = self:getTile(row,col).roomId
    isStartRoom = (roomId == startId)
  until (self:isRoom(row, col) and not isStartRoom)
  
  print(roomId, startId)
  self.rooms[roomId]:addNeighbour(startId)
  self.rooms[startId]:addNeighbour(roomId)
  
  return row, col
end
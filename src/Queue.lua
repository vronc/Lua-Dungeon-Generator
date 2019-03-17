-- source: https://www.lua.org/pil/11.4.html

Queue = {}
    function Queue.new ()
      return {first = 0, last = -1}
    end

    function Queue.pushleft (queue, value)
      local first = queue.first - 1
      queue.first = first
      queue[first] = value
    end
    
    function Queue.pushright (queue, value)
      local last = queue.last + 1
      queue.last = last
      queue[last] = value
    end
    
    function Queue.popleft (queue)
      local first = queue.first
      if first > queue.last then return "end" end
      local value = queue[first]
      queue[first] = nil        -- to allow garbage collection
      queue.first = first + 1
      return value
    end
    
    function Queue.popright (queue)
      local last = queue.last
      if queue.first > last then return "end" end
      local value = queue[last]
      queue[last] = nil         -- to allow garbage collection
      queue.last = last - 1
      return value
    end
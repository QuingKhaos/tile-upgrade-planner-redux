local queue = {}

local function pop(self)
  local out = self[self.front]

  self[self.front] = nil
  self.front = self.front + 1

  return out
end

local function push(self, elem)
  self[self.back] = elem
  self.back = self.back + 1
end

local function size(self)
  return self.front - self.back
end

function queue.new()
  return {
    front = 1,
    back = 1,
    pop = pop,
    push = push,
    size = size,
  }
end

function queue.rebuild(tab)
  tab.pop = pop
  tab.push = push
  tab.size = size
end

return queue

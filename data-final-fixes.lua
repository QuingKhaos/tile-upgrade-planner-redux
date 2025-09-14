
local shared = require("shared")
local tiles = {}
local size = 1

for name, proto in pairs(data.raw["item"]) do
  if proto.place_as_tile and proto.place_as_tile.result then
    tiles[size] = proto.place_as_tile.result
    size = size + 1
  end
end

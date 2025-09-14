function check_for_active_mod(name)
  if not name then return false end

  if mods and mods[name] then
    return true
  end

  if script and script.active_mods[name] then
    return true
  end

  return false
end

local blacklist = {
  "landfill"
}

local tile_filters = {{filter="item-to-place"}}
--[[
for _, v in pairs(blacklist) do
  tile_filters[#tile_filters + 1] = {
    filter = "name",
    name = v,
    mode = "and",
    invert = true
  }
end
--]]

return {
  names = {
    planner = "tile-upgrade-planner",
    mod = "tile-upgrade-planner-redux",
    add_row = "tile-upgrade-add-row",
    remove_row = "tile-upgrade-remove-row",
  },

  tile_filters = tile_filters,
}

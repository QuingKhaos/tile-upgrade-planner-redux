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

  default_mapping = {
    {source = "stone-path", target = "concrete"},
    {source = "concrete", target = "refined-concrete"},
    {source = "hazard-concrete-left", target = "refined-hazard-concrete-left"},
    {source = "hazard-concrete-right", target = "refined-hazard-concrete-right"},
  },
}

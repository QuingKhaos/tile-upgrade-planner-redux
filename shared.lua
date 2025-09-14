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

local default_mapping = {
  {source = "stone-path", target = "concrete"},
  {source = "concrete", target = "refined-concrete"},
  {source = "hazard-concrete-left", target = "refined-hazard-concrete-left"},
  {source = "hazard-concrete-right", target = "refined-hazard-concrete-right"},
}

-- Electric Tiles support
if check_for_active_mod("electric-tiles") then
  default_mapping = {
    {source = "stone-path", target = "F077ET-stone-path"},
    {source = "concrete", target = "F077ET-concrete"},
    {source = "refined-concrete", target = "F077ET-refined-concrete"},
    {source = "hazard-concrete-left", target = "F077ET-hazard-concrete-left"},
    {source = "hazard-concrete-right", target = "F077ET-hazard-concrete-right"},
    {source = "refined-hazard-concrete-left", target = "F077ET-refined-hazard-concrete-left"},
    {source = "refined-hazard-concrete-right", target = "F077ET-refined-hazard-concrete-right"},
  }
end

return {
  names = {
    planner = "tile-upgrade-planner",
    mod = "tile-upgrade-planner-redux",
    add_row = "tile-upgrade-add-row",
    remove_row = "tile-upgrade-remove-row",
  },

  tile_filters = tile_filters,
  default_mapping = default_mapping
}

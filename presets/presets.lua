-- Only one of these presets can be used.
-- The preset with the highest number of "required mods" matches will be selected.

-- If you would like to add a preset for your own mod, you will need to implement the remote interface. Please see the README for more info.

presets = {
  ["Vanilla"] = {
    required_mods = {},
    tile_mappings = {
      {source = "stone-path", target = "concrete"},
      {source = "concrete", target = "refined-concrete"},
      {source = "hazard-concrete-left", target = "refined-hazard-concrete-left"},
      {source = "hazard-concrete-right", target = "refined-hazard-concrete-right"},
    },
  },

  ["Electric Tiles"] = {
    required_mods = {"electric-tiles"},
    tile_mappings = {
      {source = "stone-path", target = "F077ET-stone-path"},
      {source = "concrete", target = "F077ET-concrete"},
      {source = "refined-concrete", target = "F077ET-refined-concrete"},
      {source = "hazard-concrete-left", target = "F077ET-hazard-concrete-left"},
      {source = "hazard-concrete-right", target = "F077ET-hazard-concrete-right"},
      {source = "refined-hazard-concrete-left", target = "F077ET-refined-hazard-concrete-left"},
      {source = "refined-hazard-concrete-right", target = "F077ET-refined-hazard-concrete-right"},
    },
  },
}

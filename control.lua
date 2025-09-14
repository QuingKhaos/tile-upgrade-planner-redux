require("scripts.gui")
require("scripts.planner")
require("scripts.presets_loader")

script.on_init(function(event)
  storage = {
    guis = {},
    planner = {},
    tasks = {front = 1, back = 1},
  }

  load_presets()
  load_preset_addons()
end)

script.on_configuration_changed(function(event)
  if next(event.mod_changes) ~= nil then
    load_presets()
    load_preset_addons()
  end
end)

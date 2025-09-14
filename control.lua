require("scripts.gui")
require("scripts.planner")
require("scripts.presets_loader")

script.on_init(function(event)
  storage = {
    guis = {},
    planner = {},
    tasks = {front = 1, back = 1},
  }

  fetch_remote_presets()
  add_remote_presets_to_preset_tables()
  load_presets()
  load_preset_addons()
end)

script.on_load(function()
    add_remote_presets_to_preset_tables()
end)

script.on_configuration_changed(function(event)
  if next(event.mod_changes) ~= nil then
    fetch_remote_presets()
    -- on_load is called before on_configuration_changed so we have to redo add_remote_presets_to_preset_tables here
    add_remote_presets_to_preset_tables()
    load_presets()
    load_preset_addons()
  end
end)

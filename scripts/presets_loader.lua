local table = require("__flib__.table")

require("presets.presets")
require("presets.preset_addons")

function is_preset_mods_enabled(preset)
  local forbidden_mods = preset.forbidden_mods or {}

  for _, mod_name in pairs(preset.required_mods) do
    if not script.active_mods[mod_name] then return false end
  end

  for _, mod_name in pairs(forbidden_mods) do
    if script.active_mods[mod_name] then return false end
  end

  return true
end

function get_auto_detected_preset_name()
  local chosen_preset_name
  local max_nb_mods_matched = -1

  for _, preset_name in pairs(storage.valid_preset_names) do
    local preset = presets[preset_name]

    if preset and #preset.required_mods > max_nb_mods_matched then
      max_nb_mods_matched = #preset.required_mods
      chosen_preset_name = preset_name
    end
  end

  return chosen_preset_name
end

function load_presets()
  storage.valid_preset_names = {"Empty"}

  for preset_name, preset in pairs(presets) do
    if is_preset_mods_enabled(preset) then
      table.insert(storage.valid_preset_names, preset_name)
    end
  end

  log("Valid presets found: " .. serpent.line(storage.valid_preset_names))

  storage.current_preset_name = get_auto_detected_preset_name()
  log("Auto-detected preset used: " .. storage.current_preset_name)
  storage.loaded_tile_mappings = table.deep_copy(presets[storage.current_preset_name].tile_mappings)
end

function load_preset_addons()
  local preset_addons_loaded = {}

  for preset_addon_name, preset_addon in pairs(preset_addons) do
    if is_preset_mods_enabled(preset_addon) then
      table.insert(preset_addons_loaded, preset_addon_name)

      for _, tile_mapping in pairs(preset_addon.tile_mappings) do
        table.insert(storage.loaded_tile_mappings, tile_mapping)
      end
    end
  end

  log("Preset addons loaded: " .. serpent.line(preset_addons_loaded))
end

local table = require("__flib__.table")

require("presets.presets")
require("presets.preset_addons")

function validate_tile_mappings(tile_mappings)
  for _, tile_mapping in pairs(tile_mappings) do
    if type(tile_mapping.source) ~= "string" then
      return nil, "Invalid import string. Missing field: source"
    end

    if type(tile_mapping.target) ~= "string" then
      return nil, "Invalid import string. Missing field: target"
    end
  end

  return tile_mappings, nil
end

local function validate_tile_upgrade_planner_presets(interface_name, presets_to_validate, existing_table)
  local valid = true

  if type(presets_to_validate) ~= "table" then
    log("Interface " .. interface_name .. " should return a table.")
    valid = false
  else
    for preset_name, preset in pairs(presets_to_validate) do
      if type(preset_name) ~= "string" then
        log("Interface " .. interface_name .. " should return a table with named keys.")
        valid = false
        break
      end

      if existing_table[preset_name] then
        log("Preset " .. preset_name .. " already exists. Overriding.")
      end

      if not preset.required_mods then
        log("Preset " .. preset_name .. " is missing a `required_mods` value.")
        valid = false
      end

      if not preset.tile_mappings then
        log("Preset " .. preset_name .. " is missing a `tile_mappings` value.")
        valid = false
      else
        _, error = validate_tile_mappings(preset.tile_mappings)

        if error then
          log("Preset " .. preset_name .. ": " .. error)
          valid = false
        end
      end
    end
  end

  if not valid then
    log("Please warn the mod author for " .. interface_name .. " about the errors above.")
  end

  return valid
end

local function validate_and_add_to_preset_table(interface_name, remote_tile_upgrade_planner_presets, existing_table)
  if validate_tile_upgrade_planner_presets(interface_name, remote_tile_upgrade_planner_presets, existing_table) then
    ---@cast remote_tile_upgrade_planner_presets table
    for remote_preset_name, remote_preset in pairs(remote_tile_upgrade_planner_presets) do
      existing_table[remote_preset_name] = remote_preset
    end
  end
end

function fetch_remote_presets()
  -- See presets.lua to find out how to use these reverse remote interface to add your own preset or preset addon.
  storage.remote_presets = {}
  storage.remote_preset_addons = {}

  for interface_name, functions in pairs(remote.interfaces) do
    if functions["tile_upgrade_planner_presets"] then
      local remote_tile_upgrade_planner_presets = remote.call(interface_name, "tile_upgrade_planner_presets")
      validate_and_add_to_preset_table("tile_upgrade_planner_presets", remote_tile_upgrade_planner_presets, storage.remote_presets)
    end

    if functions["tile_upgrade_planner_preset_addons"] then
      local remote_tile_upgrade_planner_preset_addons = remote.call(interface_name, "tile_upgrade_planner_preset_addons")
      validate_and_add_to_preset_table("tile_upgrade_planner_preset_addons", remote_tile_upgrade_planner_preset_addons, storage.remote_preset_addons)
    end
  end
end

function add_remote_presets_to_preset_tables()
  if storage.remote_presets then -- Should always be set in on_init, but just for migration safety
    for remote_preset_name, remote_preset in pairs(storage.remote_presets) do
      presets[remote_preset_name] = remote_preset
    end
  end

  if storage.remote_preset_addons then
    for remote_preset_name, remote_preset in pairs(storage.remote_preset_addons) do
      preset_addons[remote_preset_name] = remote_preset
    end
  end
end

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

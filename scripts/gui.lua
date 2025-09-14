local util = require("util")
local shared = require("shared")

function verify_filters(filters)
  local output = {}
  local tiles = prototypes.get_tile_filtered({{filter="item-to-place"}})

  for k, filter in pairs(filters) do
    output[k] = {}

    if filter.source and tiles[filter.source] then
      output[k].source = filter.source
    end

    if filter.target and tiles[filter.target] then
      output[k].target = filter.target
    end
  end

  return output
end

function update_planner(event)
  if event.element.get_mod() ~= shared.names.mod then return end

  local player = game.get_player(event.player_index)
  local planner = player.cursor_stack

  if planner.valid_for_read and planner.name == shared.names.planner then
    local item_number = player.cursor_stack.item_number

    if item_number then
      local _, _, type, number = string.find(event.element.name, "(.*)%-(%d+)")

      if type and number and (type == "source" or type == "target") then
        local planner_data = storage.planner[item_number]

        planner_data[tonumber(number)] = planner_data[tonumber(number)] or {}
        planner_data[tonumber(number)][type] = event.element.elem_value
      end
    end

    update_label(planner, item_number)
  end
end

function update_label(planner, planner_number)
  --[[
  local planner_data = storage.planner[planner_number]
  local label = ""

  for k, v in pairs(planner_data) do
    if v.source and v.target then
      local new_line = ""

      if label ~= "" then
        new_line = "\n"
      end

      label = label .. new_line .. "[tile = " .. v.source .. "] -> [tile = " .. v.target .. "]"
    end
  end

  planner.label = label
  --]]
end

function save_planner(root, planner_id)
  local table = root["table"]

  if not storage.planner[planner_id] then
      storage.planner[planner_id] = {}
  end

  local planner_data = storage.planner[planner_id]

  for _, child in pairs(table.children) do
    if string:find(child.name, "source") then

    elseif string:find(child.name, "target") then

    end
  end
end

function add_row(root, index)
  local table = root["table"]

  if table["add-row"] then
    table["add-row"].destroy()
  end

  table.add{type = "choose-elem-button", name = "source-"..index, elem_type = "tile", elem_filters = shared.tile_filters}
  table.add{type = "label", name = "arrow-"..index, caption = "->"}
  table.add{type = "choose-elem-button", name = "target-"..index, elem_type = "tile", elem_filters = shared.tile_filters}
  table.add{type = "sprite-button", name = "remove-"..index, tooltip = {"tile-upgrade-planner.remove-row"}, sprite = shared.names.remove_row, style = "frame_action_button"}
  table.add{type = "sprite-button", name = "add-row", tooltip = {"tile-upgrade-planner.add-row"}, sprite = shared.names.add_row}
end

function rebuild_planner(player, table, planner_id)
  local filters = verify_filters(storage.planner[planner_id])

  for k, v in pairs(filters) do
    if v then
      table.add{type = "choose-elem-button", name = "source-"..k, elem_type = "tile", tile = v.source, elem_filters = shared.tile_filters}
      table.add{type = "label", name = "arrow-"..k, caption = "->"}
      table.add{type = "choose-elem-button", name = "target-"..k, elem_type = "tile", tile = v.target, elem_filters = shared.tile_filters}
      table.add{type = "sprite-button", name = "remove-"..k, tooltip = {"tile-upgrade-planner.remove-row"}, sprite = shared.names.remove_row, style = "frame_action_button"}
    end
  end

  table.add{type = "sprite-button", name = "add-row", tooltip = {"tile-upgrade-planner.add-row"}, sprite = shared.names.add_row}
end

function create_planner(player, table, planner_id)
  storage.planner[planner_id] = storage.planner[planner_id] or util.copy(shared.default_mapping)
end

function open_planner(player, planner_id)
  local root = player.gui.left.add{type = "frame", name = "tile-upgrade-planner", caption={"item-name.tile-upgrade-planner"}}
  local table = root.add{type="table", name="table", column_count=4}

  table.add{type = "label", caption = {"gui-upgrade.from"}}
  table.add{type = "label", caption = ""}
  table.add{type = "label", caption = {"gui-upgrade.to"}}
  table.add{type  ="label", caption = ""}

  if not storage.planner[planner_id] then
    create_planner(player, table, planner_id)
  end

  rebuild_planner(player, table, planner_id)

  storage.guis[player.index] = root
end

function close_planner(player_index)
  storage.guis[player_index].destroy()
  storage.guis[player_index] = nil
end

function remove_row(event)
  local row = nil
  _, _, row = string.find(event.element.name, "remove%-(%d+)")

  if row then
    row = tonumber(row)

    local player = game.get_player(event.player_index)
    local planner = player.cursor_stack

    if planner.valid_for_read and planner.name == shared.names.planner then
      local planner_id = planner.item_number
      local planner_data = storage.planner[planner_id]

      table.remove(planner_data, row)

      close_planner(event.player_index)
      open_planner(player, planner_id)
      update_label(planner, planner_id)
    end
  end
end

function planner_add_row(event)
  if event.element.get_mod() ~= shared.names.mod then return end

  if event.element.name == "add-row" then
    local player = game.get_player(event.player_index)
    local root = storage.guis[event.player_index]
    local planner_id = player.cursor_stack.valid_for_read and player.cursor_stack.item_number

    if planner_id then
      local planner_data = storage.planner[planner_id]

      add_row(root, #planner_data +1)
      planner_data[#planner_data+1] = {}
    end
  end
end

script.on_init(function(event)
  storage = {
    guis = {},
    planner = {},
    tasks = {front = 1, back = 1},
  }
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  local cursor_stack = player.cursor_stack

  if storage.guis[event.player_index] then
    close_planner(event.player_index)
  end

  if cursor_stack.valid_for_read and cursor_stack.name == shared.names.planner then
    open_planner(player, cursor_stack.item_number)
  end
end)

script.on_event(defines.events.on_gui_elem_changed, update_planner)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.get_mod() ~= shared.names.mod then return end

  if event.element.name == "add-row" then
    planner_add_row(event)
  else
    remove_row(event)
  end
end)

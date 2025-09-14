local shared = require("shared")
local util = require("util")

local function invert_table(tab)
  local out = {}
  local i = 1

  for k,v in pairs(tab) do
    out[i] = k
    i = i + 1
  end

  return out
end

local function get_filters(planner_data)
  local out = {}

  for _,v in pairs(planner_data) do
    if v.source and v.target then
      out[v.source] = v.target
    end
  end

  return out
end

local function area_size(area)
    return (area.right_bottom.x - area.left_top.x) * (area.right_bottom.y - area.left_top.y)
end

local function enqueue_area(player_id, surface_id, area, filters)
  local queue = storage.tasks
  local block_size = 1024

  for x = area.left_top.x, area.right_bottom.x, block_size do
    for y = area.left_top.y, area.right_bottom.y, block_size do
      local left_top = {x=x, y=y}
      local right_bottom = {x= math.min(x+block_size, area.right_bottom.x), y=math.min(y+block_size,area.right_bottom.y)}

      queue[queue.back] = {
        player_id = player_id,
        surface_id=surface_id,
        area = {
          left_top=left_top,
          right_bottom=right_bottom,
        },
        filters=filters,
      }

      queue.back = queue.back + 1
    end
  end
end

local function upgrade_area(player_id, surface_id, area, filters)
  local player = game.get_player(player_id)
  local force = player.force
  local surface = game.get_surface(surface_id)
  local filters_inv = invert_table(filters)
  local upgrade_locations = {}
  local item_index = 0

  for _, ghost in pairs(surface.find_entities_filtered({area=area, name="tile-ghost", force=force})) do
    local ghost_name = ghost.ghost_name
    local position = ghost.position

    if filters[ghost_name] then
      if surface.get_tile(position).name ~= filters[ghost_name] then
        surface.create_entity{name="tile-ghost", position=position, force=force, player=player, item_index = item_index, raise_built=true, inner_name=filters[ghost_name]}
        item_index = 1
      end

      ghost.destroy()
    end

    upgrade_locations[position.x-0.5 .. "," ..position.y-0.5] = true
  end

  local tiles = surface.find_tiles_filtered({area=area, name=filters_inv})

  for _,tile in pairs(tiles) do
    local tile_name = tile.name
    local tile_position = tile.position

    if filters[tile_name] and not upgrade_locations[tile_position.x .. "," ..tile_position.y] then
      surface.create_entity{name="tile-ghost", position=tile_position, force=force, item_index = item_index, player=player, raise_built=true, inner_name=filters[tile_name]}
      item_index = 1
    end
  end
end

local function selected_area(event, reverse)
  local player = game.get_player(event.player_index)
  local planner = player.cursor_stack

  if planner then
    if planner.valid_for_read and planner.name == shared.names.planner then
      local filters = util.copy(storage.planner[planner.item_number])

      if reverse then
        for _, v in pairs(filters) do
          v.source, v.target = v.target, v.source
        end
      end

      if area_size(event.area) > 100000 then
        enqueue_area(event.player_index, event.surface.index, event.area, get_filters(filters))
      else
        upgrade_area(event.player_index, event.surface.index, event.area, get_filters(filters))
      end
    end
  end
end

local function process_queue(event)
  local queue = storage.tasks

  if queue[queue.front] then
    local data = queue[queue.front]

    if data.filters then
      upgrade_area(data.player_id, data.surface_id, data.area, data.filters)
    else
      clear_area(data.player_id, data.surface_id, data.area, data.filters)
    end

    queue[queue.front] = nil
    queue.front = queue.front + 1

    if queue.front >= queue.back then
      queue.front = 1
      queue.back = 1
    end
  end
end

function clear_area(player_id, surface_id, area, filters)
  local surface = game.get_surface(surface_id)
  local player = game.get_player(player_id)
  local force = player.force

  for _, ghost in pairs(surface.find_entities_filtered{area = area, name = "tile-ghost", force = force}) do
    ghost.destroy()
  end
end

local function deselected_area(event)
  if event.item == shared.names.planner then
    for _, ent in pairs(event.entities) do
      ent.destroy()
    end
  end
end

script.on_event(defines.events.on_player_selected_area, function(event) selected_area(event, false) end)
script.on_event(defines.events.on_player_reverse_selected_area, function(event) selected_area(event, true) end)
script.on_event(defines.events.on_player_alt_selected_area, deselected_area)
script.on_nth_tick(60, process_queue)

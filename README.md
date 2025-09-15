[![Factorio Mod Portal page](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Ftile-upgrade-planner-redux&style=for-the-badge)](https://mods.factorio.com/mod/tile-upgrade-planner-redux) [![Crowdin Translate](https://img.shields.io/badge/Crowdin-Translate-brightgreen?style=for-the-badge)](https://crowdin.com/project/factorio-mods-localization) [![](https://img.shields.io/github/issues/QuingKhaos/tile-upgrade-planner-redux/bug?label=Bug%20Reports&style=for-the-badge)](https://github.com/QuingKhaos/tile-upgrade-planner-redux/issues?q=is%3Aissue%20state%3Aopen%20label%3Abug) [![](https://img.shields.io/github/issues-pr/QuingKhaos/tile-upgrade-planner-redux?label=Pull%20Requests&style=for-the-badge)](https://github.com/QuingKhaos/tile-upgrade-planner-redux/pulls)

# Tile Upgrade Planner Redux

Adds an upgrade planner that can be used to upgrade tiles. Redux fork with additional features and bug fixes.

Hold the upgrade planner in your hand to configure it. Hold shift to clear tile ghosts.

## Mod compatibility

The tile upgrade planner should be compatible with any tile from other mods. If the following mods are detected, the default config is changed accordingly.

- [Electric Tiles](https://mods.factorio.com/mod/electric-tiles): The default config is completely replaced with an upgrade path to replace each vanilla tile with the corresponding electric tile.

If you want to see default config support for other mods, feel free to open a discussion thread on the mod portal or a GitHub issue. If you're a mod author, you can add your own default config as presets via remote interfaces.

### Adding your own preset (using the remote interfaces)

If your mod is an overhaul mod, or just generally does not interact well with other mods, add a preset by implementing the `tile_upgrade_planner_presets` interface. Only one preset will be chosen from the available ones.

If your mod could be used with most other mods, add a preset addon by implementing the `tile_upgrade_planner_preset_addons` interface. Any matching preset addon will add tile mappings to the preset.

#### tile_upgrade_planner_presets

```lua
remote.add_interface("my-cool-mod", {
  tile_upgrade_planner_presets = function()
    return {
      ["My Cool Mod"] = {
        required_mods = {"my-cool-mod"},
        tile_mappings = {
          {source = "my-cool-source-tile", target = "my-cool-target-tile"},
        },
      },
    }
  end
})
```

You can take a look at examples in [`presets.lua`](presets/presets.lua).

#### tile_upgrade_planner_preset_addons

```lua
remote.add_interface("my-cool-addon", {
  tile_upgrade_planner_preset_addons = function()
    return {
      ["My Cool Addon Mod"] = {
        required_mods = {"my-cool-addon-mod"},
        tile_mappings = {
          {source = "my-cool-source-tile", target = "my-cool-target-tile"},
        },
      },
    }
  end
})
```

## Credits

- Thanks to [calcwizard](https://mods.factorio.com/user/calcwizard) for creating the original mod.
- Thanks to [MeteorSwarm](https://mods.factorio.com/user/MeteorSwarm) for the improvements in their Muluna fork.
- Thanks to the [Milestones](https://mods.factorio.com/mod/Milestones) mod, which was a good template to implement to presets feature and remote interface.

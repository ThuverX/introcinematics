function _include(file)
    dofile(VisualOverhaulCore.PATHS.lua .. file)
end

if not Log then
    function Log(...) end
end


if not VisualOverhaulCore then
    VisualOverhaulCore = {}

    VisualOverhaulCore.PATHS = {
        assets = ModPath .. "assets/",
        lua = ModPath .. "lua/",
        locales = ModPath .. "locales/"
    }

    VisualOverhaulCore.HOOKS = {
        ["lib/setups/setup"] = {
            "managers/HologramManager.lua",
            "managers/IntroCinematicManager.lua",
        },
        ["lib/states/ingamewaitingforplayers"] = "managers/IntroCinematicManager.lua",
        ["lib/managers/hud/hudmissionbriefing"] = "managers/IntroCinematicManager.lua",
        ["lib/managers/hud/hudblackscreen"] = "managers/IntroCinematicManager.lua",
        ["lib/managers/voicebriefingmanager"] = "managers/IntroCinematicManager.lua",
        ["lib/tweak_data/levelstweakdata"] = "tweak_data/LevelsTweakData.lua"
    }

    VisualOverhaulCore.managers = {}

    VisualOverhaulCore.global = {}

    VisualOverhaulCore.error = nil
    VisualOverhaulCore.urls = {
        BeardLib = "https://modworkshop.net/mod/14924"
    }

    function VisualOverhaulCore:check_compat()

        if not BeardLib then
            VisualOverhaulCore.error = {
                title = "Intro Cinematic mod can't be loaded",
                text = "BeardLib is required to use the Intro Cinematic mod\n ",
                button_list = {
                    {
                        text = "Download BeardLib",
                        callback_func = function()
                            Steam:overlay_activate("url", VisualOverhaulCore.urls.BeardLib)
                        end
                    }
                }
            }

            return false
        end

        return true
    end

    function VisualOverhaulCore:process_requires()
        _include("tweak_data/Globals.lua")

        if RequiredScript then
            local hook_list = VisualOverhaulCore.HOOKS[RequiredScript:lower()]
            if hook_list then
                if type(hook_list) == "string" then
                    hook_list = {hook_list}
                end
                for _, file_name in pairs(hook_list) do
                    dofile(VisualOverhaulCore.PATHS.lua .. file_name)
                end
            end
        end
    end   
end

if VisualOverhaulCore:check_compat() then
    VisualOverhaulCore:process_requires()
end

if RequiredScript:lower() == "lib/managers/menu/menucomponentmanager" then

    -- Error reporting / compat

    Hooks:PostHook(MenuComponentManager, "create_player_profile_gui", "F_"..Idstring("PostHook:MenuComponentManager:create_player_profile_gui"):key(), function(self)
        if VisualOverhaulCore.error and VisualOverhaulCore.error.title then
            managers.system_menu:show(VisualOverhaulCore.error)
        end
    end)
end

if RequiredScript:lower() == "core/lib/setups/coresetup" then

    -- Global updater

    Hooks:PostHook(CoreSetup, "__update", "F_"..Idstring("PostHook:CoreSetup:__update"):key(), function(self,t,dt)
        if VisualOverhaulCore.managers.holograms then
            VisualOverhaulCore.managers.holograms:update(t,dt)
        end
    end)
end
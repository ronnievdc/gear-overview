GearOverview = {}
local lib = GearOverview

lib.name = "GearOverview"
lib.author = "@ronnievdc"
lib.version = "0.2.0"
lib.custom = false
lib.customList = {}
lib.presets = {}
lib.activePreset = nil
lib.bag = {}
lib.setNameToId = {}

local logger

lib.LOG_LEVEL_VERBOSE = "V"
lib.LOG_LEVEL_DEBUG = "D"
lib.LOG_LEVEL_INFO = "I"
lib.LOG_LEVEL_WARNING = "W"
lib.LOG_LEVEL_ERROR = "E"

if LibDebugLogger then
    logger = LibDebugLogger.Create(lib.name)
end

--- Log a line to debuglogger
--- @param level string LOG_LEVEL_X
--- @return void
lib.log = function(level, ...)
    if logger == nil then
        return
    end
    if type(logger.Log) == "function" then
        logger:Log(level, ...)
    end
end

SLASH_COMMANDS['/showgearlist'] = lib.showWindow

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
--- Fired when an addon is loaded
--- @param event table
--- @param addonName string The name of the loaded addon
--- @return void
function lib.OnAddOnLoaded(event, addonName)
    if addonName ~= lib.name then
        return
    end
    lib:Initialize()
end

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
------ Fired when this addon is loaded
----- @return void
function lib:Initialize()
    lib.log(lib.LOG_LEVEL_DEBUG, lib.name .. ":Initialize")
    EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)

    lib.scrollList = lib.CreateScrollList()
    lib.createSettings()
    local fragment = ZO_SimpleSceneFragment:New(GearOverviewList)
    lib.scene = ZO_Scene:New("GearOverviewList", SCENE_MANAGER)
    lib.scene:AddFragment(fragment)

    lib.scanSets()
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
lib.log(lib.LOG_LEVEL_DEBUG, "register for event addon loaded")
EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_ADD_ON_LOADED, lib.OnAddOnLoaded)
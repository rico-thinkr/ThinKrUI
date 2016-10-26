--[[
核心文件
主要定义了事件的注册器。
定义了UI手动缩放事件，自动缩放事件。
]]

local addon,core=...

core[1] = {} -- F, Functions 函数数组
core[2] = {} -- C，Constants/Config 常量/设置
core[3] = {} -- L, Localisation 本地化

ThinkrUI= core

local F,C,L =unpack(select(2,...))

-- [[全局设置]]
ThinkrUIGlobalConfig = {}

-- [[单个角色设置]]
ThinkrUIConfig = {}

-- [[事件 处理器]]

local eventFrame = CreateFrame("Frame");
local events = {} -- 事件数组

-- [[事件触发函数]]
eventFrame:SetScript('OnEvent',function(_,event,...)
    for i=#events[event],1,-1 do
      -- body...
      events[event][i](event,...)
    end
  end
)

--[[
注册事件函数
event 事件名称
func 执行函数
]]
F.RegisterEvent = function(event,func)
  if not events[event] then
    events[event] = {}
    eventFrame:RegisterEvent(event)
  end
  table.insert(events[event],func)
end

-- [[注销事件]]
F.UnregisterEvent = function(event, func)
  for index, tFunc in ipairs(events[event]) do
    if tFunc == func then
      table.remove(events[event], index)
    end
  end
  if #events[event] == 0 then
    events[event] = nil
    eventFrame:UnregisterEvent(event)
  end
end

-- [[注销全部事件]]
F.UnregisterAllEvents = function(func)
  for event in next, events do
    F.UnregisterEvent(event, func)
  end
end

-- [[DEBUG 事件]]
F.debugEvents = function()
  for event in next, events do
    print(event..": "..#events[event])
  end
end

--[[
界面设置的 回调函数
catagory 类型
option 设置
func 函数
widgetType 挂件类型
--]]
F.AddOptionsCallback = function(catagory,option,func,widgetType)
  if not IsAddOnLoaded("ThinKrUI_Options") then return end
  if widgetType and widgetType =="radio" then
    local index = 1
    local frame = ThinkrUIOptionsPanel[category][option..index]
    while frame do
      frame:HookScript('OnClick',func)
      index=index+1
      frame = ThinkrUIOptionsPanel[category][option..index]
    end
  else
    local frame = FreeUIOptionsPanel[category][option]
    if frame:GetObjectType() == "Slider" then
      frame:HookScript("OnValueChanged", func)
    else
      frame:HookScript("OnClick", func)
    end
  end
end

-- [[分辨率支持]]

C.RESOLUTION_SMALL = 1 --低
C.RESOLUTION_MEDIUM = 2 --中
C.RESOLUTION_LARGE = 3 --高

C.resolution = 0

--[[ 更新界面的UI 缩放]]
local updateScale
updateScale = function(event)
  -- [[加载设置后，根据当前屏幕高度设置分辨率大小]]
  if event=="VARIABLES_LOADED" then
    local height = GetScreenHeight() -- 获取屏幕高度
    if height<=900 then
      C.resolution = C.RESOLUTION_SMALL
    elseif height < 1200 then
      C.resolution = C.RESOLUTION_MEDIUM
    else
      C.resolution = C.RESOLUTION_LARGE
    end
  end

  if C.general.uiScaleAuto then
    if not InCombatLockdown() then
      -- we don't bother with the cvar because of high resolution shenanigans
      UIParent:SetScale(768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
      ChatFrame1:ClearAllPoints()
      ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 30, 30)
    else
      F.RegisterEvent("PLAYER_REGEN_ENABLED", updateScale)
    end

    if event == "PLAYER_REGEN_ENABLED" then
      F.UnregisterEvent("PLAYER_REGEN_ENABLED", updateScale)
    end
  end
end

F.RegisterEvent("VARIABLES_LOADED", updateScale)
F.RegisterEvent("UI_SCALE_CHANGED", updateScale)

-- [[设置为自动缩放UI]]
F.AddOptionsCallback("general", "uiScaleAuto", function()
    if C.general.uiScaleAuto then
      F.RegisterEvent("UI_SCALE_CHANGED", updateScale)
      updateScale()
    else
      F.UnregisterEvent("UI_SCALE_CHANGED", updateScale)
    end
  end)

-- [[ For secure frame hiding ]]

local hider = CreateFrame("Frame", "FreeUIHider", UIParent)
hider:Hide()

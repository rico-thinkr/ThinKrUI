local F,C =unpack(select(2,...)) --导入 Functions,Constants

if not IsAddOnLoaded("ThinKrUI_Options") then return end

local realm = GetRealmName()
local name = UnitName("player")

--[[判断是否存在配置文件。如果不存在，则设置配为空]]
if not ThinKrUIOptionsGlobal then
    ThinKrUIOptionsGlobal = {}
end

if ThinKrUIOptionsGlobal[realm]== nil then
    ThinKrUIOptionsGlobal[realm] = {}
end

if ThinKrUIOptionsGlobal[realm][name]==nil then
    ThinKrUIOptionsGlobal[realm][name]= false
end

--[[创建主配置表]]
if ThinKrUIOptions == nil then
    ThinKrUIOptions = {}
end

--[[每个角色的配置文件]]
local profile
if ThinKrUIOptionsGlobal[realm][name]==true then
    if ThinKrUIOptionsPerChar ==nil then
        ThinKrUIOptionsPerChar = {}
    end
    profile = ThinKrUIOptionsPerChar
else
    profile = ThinKrUIOptions
end
--[[应用配置/删除配置]]
for group ,options in pairs(profile) do
    if C[group] then
        for option ,value in pairs(options) do
            if C[group][option]==nil or C[group][option]==value then
                profile[group][option]=nil
            else
                C[group][option]=value
            end
        end
    else
        profile[group]=nil
    end
end
C.options = profile

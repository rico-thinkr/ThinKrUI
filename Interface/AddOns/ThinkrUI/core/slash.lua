local F, C, L = unpack(select(2, ...))

SlashCmdList.FRAMENAME = function()
    print(GetMouseFocus():GetName())
end
SLASH_FRAMENAME1 ="/gn"

SlashCmdList.GETPARENT = function()
    print(GetMouseFocus():GetParent():GetName())
end
SLASH_GETPARENT1 = "/gp"

SlashCmdList.DISABLE_ADDON = function(s)
    DisableAddOn(s)
end
SLASH_DISABLE_ADDON1 = "/dis"

SlashCmdList.ENABLE_ADDON = function(s)
    EnableAddOn(s)
end
SLASH_ENABLE_ADDON1 = "/en"

SlashCmdList.RELOADUI = ReloadUI
SLASH_RELOADUI1 = "/rl"

SlashCmdList.RCSLASH = DoReadyCheck
SLASH_RCSLASH1 = "/rc"

SlashCmdList.ROLECHECK = InitiateRolePoll
SLASH_ROLECHECK1 = "/rolecheck"
SLASH_ROLECHECK2 = "/rolepoll"

SlashCmdList.TICKET = ToggleHelpFrame
SLASH_TICKET1 = "/gm"


SlashCmdList.VOLUME = function(value)
	local numValue = tonumber(value)
	if numValue and 0 <= numValue and numValue <= 1 then
		SetCVar("Sound_MasterVolume", numValue)
	end
end
SLASH_VOLUME1 = "/vol"


SlashCmdList.GPOINT = function(f)
	if f ~= "" then
		f = _G[f]
	else
		f = GetMouseFocus()
	end

	if f ~= nil then
		local a1, p, a2, x, y = f:GetPoint()
		print("|cffFFD100"..a1.."|r "..p:GetName().."|cffFFD100 "..a2.."|r "..x.." "..y)
	end
end

SLASH_GPOINT1 = "/gpoint"

SlashCmdList.FPS = function(value)
	local numValue = tonumber(value)
	if numValue and 0 <= numValue then
		SetCVar("maxFPS", numValue)
	end
end
SLASH_FPS1 = "/fps"


SlashCmdList.THINKRUI = function(cmd)
	local cmd, args = strsplit(" ", cmd:lower(), 2)
	if C.unitframes.enable then
		if cmd == "dps" then
			ThinKrUIConfig.layout = 1
			ReloadUI()
		elseif(cmd == "heal" or cmd == "healer") then
			ThinKrConfig.layout = 2
			ReloadUI()
		end
	end

	if cmd == "install" then
		if IsAddOnLoaded("ThinKrUI_Install") then
			ThinKrUI_InstallFrame:Show()
		else
			EnableAddOn("ThinKrUI_Install")
			LoadAddOn("ThinKrUI_Install")
		end
	elseif cmd == "reset" then
		ThinKrUIGlobalConfig = {}
		ThinKrUIConfig = {}
		ReloadUI()
	else
		if not BankFrame:IsShown() and ThinKrUIOptionsPanel then
			ThinKrUIOptionsPanel:Show()
		end
		DEFAULT_CHAT_FRAME:AddMessage("ThinKrUI |cffffffff"..GetAddOnMetadata("ThinKrUI", "Version"), unpack(C.class))
		if C.unitframes.enable then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffffff/tkui|r [输出/治疗]|cffffffff: 选择一个框架布局|r", unpack(C.class))
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff/tkui|r install|cffffffff: 安装|r", unpack(C.class))
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff/tkui|r reset|cffffffff: 重置|r", unpack(C.class))
	end
end
SLASH_FREEUI1 = "/tkui"

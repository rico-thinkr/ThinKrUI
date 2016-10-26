local F, C, L = unpack(select(2, ...))

local name = UnitName("player")
local realm = GetRealmName()
local r, g, b = unpack(C.class)
local keys = {}

-- [[ Initialize / load variables ]]

local addonLoaded
addonLoaded = function(_, addon)
	if addon ~= "ThinKrUI" then return end

	if ThinKrUIGlobalConfig[realm] == nil then ThinKrUIGlobalConfig[realm] = {} end

	if ThinKrUIGlobalConfig[realm].gold == nil then ThinKrUIGlobalConfig[realm].gold = {} end

	if ThinKrUIGlobalConfig[realm].class == nil then ThinKrUIGlobalConfig[realm].class = {} end
	ThinKrUIGlobalConfig[realm].class[name] = select(2, UnitClass("player"))

	if ThinKrUIGlobalConfig[realm].faction == nil then ThinKrUIGlobalConfig[realm].faction = {} end
	ThinKrUIGlobalConfig[realm].faction[name] = UnitFactionGroup("player")

	F.UnregisterEvent("ADDON_LOADED", addonLoaded)
	addonLoaded = nil
end

F.RegisterEvent("ADDON_LOADED", addonLoaded)

-- [[ Update money amount ]]

local function updateMoney()
	ThinKrUIGlobalConfig[realm].gold[name] = GetMoney()
end

F.RegisterEvent("PLAYER_MONEY", updateMoney)
F.RegisterEvent("PLAYER_ENTERING_WORLD", updateMoney)

-- [[ Money tooltip ]]

local function Format(money)
	return format("%s\124TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0\124t", BreakUpLargeNumbers(floor((money / 10000) + .5)))
end

local function ShowMoney()
	GameTooltip:SetOwner(ContainerFrame1MoneyFrameGoldButton, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", BagsHolder, "BOTTOMLEFT", -1, -1)

	local total, totalAlliance, totalHorde, totalNeutral = 0, 0, 0, 0
	local goldList = ThinKrUIGlobalConfig[realm].gold
	local factionList = ThinKrUIGlobalConfig[realm].faction
	local allianceList, hordeList, neutralList = {}, {}, {}
	local headerAdded = false

	for k, v in pairs(goldList) do
		if factionList[k] == "Alliance" then
			totalAlliance = totalAlliance + v
			allianceList[k] = v
		elseif factionList[k] == "Horde" then
			totalHorde = totalHorde + v
			hordeList[k]= v
		else
			totalNeutral = totalNeutral + v
			neutralList[k] = v
		end

		total = total + v
	end


	GameTooltip:AddDoubleLine(realm, Format(total), r, g, b, 1, 1, 1)

	for n in pairs(allianceList) do
		table.insert(keys, n)
	end
	table.sort(keys)

	for _, k in pairs(keys) do
		local class = ThinKrUIGlobalConfig[realm].class[k]
		local v = allianceList[k]
		if v and v >= 10000 then
			if not headerAdded then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(strupper(FACTION_ALLIANCE), Format(totalAlliance), 0, 0.68, 0.94, 1, 1, 1)
				headerAdded = true
			end
			GameTooltip:AddDoubleLine(k, Format(v), C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b, 1, 1, 1)
		end
	end

	headerAdded = false
	table.wipe(keys)

	for n in pairs(hordeList) do
		table.insert(keys, n)
	end
	table.sort(keys)

	for _, k in pairs(keys) do
		local class = ThinKrUIGlobalConfig[realm].class[k]
		local v = hordeList[k]
		if v and v >= 10000 then
			if not headerAdded then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(strupper(FACTION_HORDE), Format(totalHorde), 1, 0, 0, 1, 1, 1)
				headerAdded = true
			end
			GameTooltip:AddDoubleLine(k, Format(v), C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b, 1, 1, 1)
		end
	end

	headerAdded = false
	table.wipe(keys)

	for n in pairs(neutralList) do
		table.insert(keys, n)
	end
	table.sort(keys)

	for _, k in pairs(keys) do
		local class = ThinKrUIGlobalConfig[realm].class[k]
		local v = neutralList[k]
		if v and v >= 10000 then
			if not headerAdded then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(strupper(FACTION_OTHER), Format(totalNeutral), .9, .9, .9, 1, 1, 1)
				headerAdded = true
			end
			GameTooltip:AddDoubleLine(k, Format(v), C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

ContainerFrame1MoneyFrameGoldButton:HookScript("OnEnter", ShowMoney)
ContainerFrame1MoneyFrameSilverButton:HookScript("OnEnter", ShowMoney)
ContainerFrame1MoneyFrameCopperButton:HookScript("OnEnter", ShowMoney)
ContainerFrame1MoneyFrameGoldButton:HookScript("OnLeave", GameTooltip_Hide)
ContainerFrame1MoneyFrameSilverButton:HookScript("OnLeave", GameTooltip_Hide)
ContainerFrame1MoneyFrameCopperButton:HookScript("OnLeave", GameTooltip_Hide)

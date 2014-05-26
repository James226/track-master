-----------------------------------------------------------------------------------------------
-- Client Lua Script for TrackMaster
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- TrackMaster Module Definition
-----------------------------------------------------------------------------------------------
local TrackMaster = {} 

local TrackLine = _G['TrackMasterLibs'].TrackLine
local ColorPicker = _G['TrackMasterLibs'].ColorPicker

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local icons = {
	"Icons:Arrow",
	"AbilitiesSprites:spr_StatGolden",
	"Rows",
	"CRB_Basekit:kitIcon_Holo_UpArrow",
	"CRB_MegamapSprites:sprMap_PlayerArrow",
	"CRB_MinimapSprites:sprMM_ActiveQuestArrow",
	"CRB_MegamapSprites:sprMap_PlayerArrowBase",
	"CRB_MegamapSprites:sprMap_PlayerArrowSmall",
	"CRB_MegamapSprites:sprMap_PlayerArrowNoRing",
	"CRB_MinimapSprites:sprMM_QuestArrowActivate",
	"CRB_MinimapSprites:sprMM_QuestArrow",
	"CRB_PlayerPathSprites:sprPP_SciSpawnArrowUp",
	"CRB_MinimapSprites:sprMM_ActivePathArrow",
	"CRB_MinimapSprites:sprMM_ChallengeArrow",
	"AbilitiesSprites:btn_CloseNormal",
	"BK3:sprHolo_Accent_Circle",
	"charactercreate:sprCharC_Ico_Dominion",
	"charactercreate:sprCharC_Ico_Exile_Lrg",
	"ClientSprites:QuestJewel_Accept",
	"ClientSprites:QuestJewel_Incomplete_Grey",
	"ClientSprites:QuestJewel_Offer_Grey",
	"ClientSprites:SpellChargeEdgeGlow",
	"ClientSprites:sprItem_New",
	"achievements:sprAchievements_Icon_Complete",
	"BK3:btnHolo_ExpandCollapseNormal",
	"CM_SpellslingerSprites:sprSlinger_NodeBar_InCombatOrange",
	"ClientSprites:sprItem_NewQuest",
	"Crafting_CircuitSprites:sprCircuit_Line_GreenVertical",
	"Crafting_CoordSprites:sprCoord_Direction_NE",
	"Crafting_RunecraftingSprites:sprRunecrafting_AirFade",
	"Crafting_RunecraftingSprites:sprRunecrafting_Fire",
	"Crafting_RunecraftingSprites:sprRunecrafting_Life",
	"CRB_ActionBarFrameSprites:sprResourceBar_DodgeTogglePrompt",
	"CRB_ActionBarFrameSprites:sprResourceBar_Sprint_RunIconBlue",
	"CRB_AMPs:btn_AMPS_CircleDisabled",
	"CRB_Anim_DatachronSonarPing:sprAnim_Datachron_SonarPing_Red",
	"CRB_Anim_Spinner:sprAnim_SpinnerLarge",
	"CRB_Anim_Spinner:sprAnim_SpinnerSmall",
	"CRB_Basekit:kitIcon_Holo_Mail",
	"CRB_Basekit:kitIcon_New",
	"CRB_CharacterCreateSprites:sprCC_RaceChua",
	"CRB_ChallengeTrackerSprites:sprChallengeTypeKillLarge",
	"CRB_ChallengeTrackerSprites:sprChallengeTypeGenericLarge",
	"CRB_AMPs:btn_AMPS_CircleFlyby",
	"CRB_DatachronSprites:sprDC_DarkGreenPlayRing",
	"CRB_DatachronSprites:sprDC_GreenFlashPlayRing",
	"CRB_DatachronSprites:sprDCPP_UplinkAnimation",
	"CRB_GuildSprites:sprGuild_Skull",
	"CRB_GuildSprites:sprGuild_Lopp",
	"CRB_GuildSprites:sprGuild_Glave",
	"CRB_HUDAlerts:sprAlert_RotateAnim3",
	"CRB_MinimapSprites:sprMM_GhostFlashHighlight",
	"CRB_MinimapSprites:sprMM_GhostFlash",
	"CRB_MinimapSprites:sprMM_GhostFlashBase",
	"CRB_MinimapSprites:sprMM_PlayerMarker",
	"CRB_AMPs:btn_AMPS_CirclePressedFlyby",
	"CRB_PFrameSprites:sprPF_CombatNotification",
	"CRB_ShadowMonkSprites:sprMonkWound1",
	"CRB_ShadowMonkSprites:sprMonkDamageMeter",
	"CRB_ShadowMonkSprites:sprMonkWound4",
	"PlayerPathContent_TEMP:spr_Crafting_TEMP_Stretch_QuestZonePulse",
	"PlayerPathContent_TEMP:spr_PathExpHint",
	"PlayerPathContent_TEMP:spr_PathSol_MapIcon",
	"Spellslinger_TEMP:sprSpellslinger_TEMP_ActiveLarge",
	"CRB_Basekit:kitAccent_RightArrow_Popout",
	"CRB_CharacterCreateSprites:btnCharC_RG_ChuaDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_AuFDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_AuMNormal",
	"CRB_CharacterCreateSprites:btnCharC_RG_DrFDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_DrMDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_GrFDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_GrMDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_HuF_DomDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_HuF_ExDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_HuM_ExNormal",
	"CRB_CharacterCreateSprites:btnCharC_RG_HuM_DomDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_MeFDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_MeMDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_MoFDisabled",
	"CRB_CharacterCreateSprites:btnCharC_RG_MoMDisabled",
	"CRB_DatachronSprites:btnDCPP_SciBotOpenDisabled",
	"CRB_DatachronSprites:btnDCPP_SciBotWingsFlyby",
	"CRB_DatachronSprites:sprDC_CallSidePulseBright",
	"CRB_DatachronSprites:sprDC_CallSidePulseBase",
	"CRB_HousingPlacementSprites:btnYMoveUpLongPressedFlyby",
	"CRB_HousingPlacementSprites:btnYMoveUpShortPressedFlyby",
	"CRB_HousingPlacementSprites:btnZMoveDownShortPressedFlyby",
	"CRB_MinimapSprites:btnMM_ToggleMapNormal",
	"CRB_TargetFrameSprites:sprTF_PathScientist",
	"CRB_TargetFrameSprites:sprTF_VulnFadeIn",
	"CRB_Trading:btnTradeIncreaseLargePressed",
	"CRB_Trading:btnTradeIncreaseSmallNormal",
	"CRB_WarriorSprites:xxC_ImLtn",
	"DatachronSprites:btnNewsIconFlyby",
}

TrackMaster.Type = {
	Track = 1,
	Hook = 2
}
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function TrackMaster:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

	self.mailboxList = {}
	self.hookedFunctions = {}
	self.target = nil
	self.pinned = true
	self.alpha = 1
	self.green = CColor.new(0, 1, 0, 1)
	self.yellow = CColor.new(1, 1, 0, 1)
	self.red = CColor.new(1, 0, 0, 1)
	self.clearDistance = 100
	
	self.hooks = {}
	self.trackers = {}

	self.lineBinds = {
		hooks = {

		},
		trackers = {

		}
	}

	self.Configurations = {}

	self.lines = {}

    return o
end

function TrackMaster:Init()
    Apollo.RegisterAddon(self)
end

-----------------------------------------------------------
-- params: target - Target you wish to track, either
--                  Vector3 or Unit object
--         clearDistance - Distance in meters at which to
--                         clear the tracker 
--                         (-1 for never, nil for default)
--         line - Line number on which to track this item
-----------------------------------------------------------
function TrackMaster:SetTarget(target, clearDistance, line)
	if line == nil then
		line = 1
	end

	if target ~= nil then
		if Vector3.Is(target) then
			local coord = string.format("(%d, %d, %d)", math.floor(target.x, 0.5), math.floor(target.y, 0.5), math.floor(target.z, 0.5))
			self.trackerPanel:FindChild("Coord"):SetText(coord)
		elseif Unit.is(target) then
			self.trackerPanel:FindChild("Coord"):SetText(target:GetName() or "")
		else
			self.trackerPanel:FindChild("Coord"):SetText("")
		end
	else
		self.trackerPanel:FindChild("Coord"):SetText("")
	end

	self.lines[line]:SetTarget(target, clearDistance)
end

-----------------------------------------------------------------------------------------------
-- TrackMaster OnLoad
-----------------------------------------------------------------------------------------------
function TrackMaster:OnLoad()
    -- load our form file
    self.colorPicker = ColorPicker.new()
	self.xmlDoc = XmlDoc.CreateFromFile("TrackMaster.xml")
	local mainLine = TrackLine.new(self)
	table.insert(self.lines, mainLine)
	self.trackerPanel = Apollo.LoadForm(self.xmlDoc, "TrackerMicroPanel", nil, self)
	self.trackerPanel:FindChild("TrackList"):Show(false, true)
	self.trackerPanel:FindChild("HookList"):Show(false, true)
	self.trackerPanel:FindChild("Opacity"):Show(false, true)
end

function TrackMaster:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
	local saveData = { }
	saveData["Position"] = { }
	saveData["Position"][1], saveData["Position"][2], _,_ = self.trackerPanel:GetAnchorOffsets()
	
	saveData["Hooks"] = self.hooks
	saveData["Pinned"] = self.pinned
	saveData["Alpha"] = self.alpha
	saveData["Trackers"] = self.trackers
	saveData["LineBinds"] = self.lineBinds

	saveData.Lines = { }
	for _, line in pairs(self.lines) do
		table.insert(saveData.Lines, line:Save())
	end
	
	
	return saveData
end

function TrackMaster:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	if tData["Position"] ~= nil then
		self.trackerPanel:SetAnchorOffsets(tData["Position"][1], tData["Position"][2], tData["Position"][1] + self.trackerPanel:GetWidth(), tData["Position"][2] + self.trackerPanel:GetHeight())
	end
	
	if tData["Pinned"] ~= nil then
		self.pinned = tData["Pinned"]
	end
	self.trackerPanel:FindChild("Pin"):SetCheck(self.pinned)
	
	if not self.pinned then
		self.trackerPanel:Show(false)
	end
	
	if tData["Alpha"] ~= nil then
		self:SetAlpha(tData["Alpha"])
		self.trackerPanel:FindChild("Opacity"):FindChild("SliderBar"):SetValue(self.alpha)
	end
	
	if tData["Hooks"] == nil then
		tData["Hooks"] = {}
	end
	
	if tData["Trackers"] == nil then
		tData["Trackers"] = {}
	end

	if tData["LineBinds"] ~= nil then
		self.lineBinds = tData["LineBinds"]
	end

	if tData.Lines ~= nil then
		self.lines = {}
		for _, line in pairs(tData.Lines) do
			local l = TrackLine.new(self)
			table.insert(self.lines, l)
			l:Load(line)
		end
	end


	
	self.hooks["Target"] = tData["Hooks"]["Target"] == nil and true or tData["Hooks"]["Target"]
	self.hooks["QuestHintArrow"] = tData["Hooks"]["QuestHintArrow"] == nil and true or tData["Hooks"]["QuestHintArrow"]
	self.hooks["ZoneMap"] = tData["Hooks"]["ZoneMap"] == nil and true or tData["Hooks"]["ZoneMap"]
	self.hooks["GroupFrame"] = tData["Hooks"]["GroupFrame"] == nil and true or tData["Hooks"]["GroupFrame"]
	
	self.trackers["Focus"] = tData["Trackers"]["Focus"] == nil and false or tData["Trackers"]["Focus"]
	
	self.trackerPanel:FindChild("HookTarget"):SetCheck(self.hooks["Target"])
	self.trackerPanel:FindChild("HookQuestHintArrow"):SetCheck(self.hooks["QuestHintArrow"])
	self.trackerPanel:FindChild("HookZoneMap"):SetCheck(self.hooks["ZoneMap"])
	self.trackerPanel:FindChild("HookGroupFrame"):SetCheck(self.hooks["GroupFrame"])
	self.trackerPanel:FindChild("TrackFocus"):SetCheck(self.trackers["Focus"])
	self:UpdateHooks()
	self:UpdateTrackers()
end

-----------------------------------------------------------------------------------------------
-- TrackMaster GetAsyncLoadStatus
-----------------------------------------------------------------------------------------------
function TrackMaster:GetAsyncLoadStatus()

	-- check for external dependencies here
	if g_AddonsLoaded == nil then
		g_AddonsLoaded = {}
	end
	if not g_AddonsLoaded["QuestTracker"] and false then
		return Apollo.AddonLoadStatus.Loading
	end

	if self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "TrackMasterForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return Apollo.AddonLoadStatus.LoadingError
		end			
		
	    self.wndMain:Show(false, true)	

		Apollo.RegisterSlashCommand("mailbox", "OnMailbox", self)
		
		Apollo.RegisterSlashCommand("trackmaster", "OnShow", self)
		Apollo.RegisterSlashCommand("tmc", "OnTrackMasterOn", self)
		
		Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
		Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)

		self.timer = ApolloTimer.Create(1/60, true, "OnTimer", self)
		self.rotationTimer = ApolloTimer.Create(1/5, true, "OnRotation", self)
		--Apollo.RegisterEventHandler("NextFrame", "OnTimer", self)
		

		local iconPicker = self.wndMain:FindChild("IconPicker"):FindChild("IconList")
		iconPicker:DestroyChildren()
		for _, icon in pairs(icons) do
			local iconButton = Apollo.LoadForm(self.xmlDoc, "TrackMasterForm.IconPicker.IconList.IconPickerButton", iconPicker, self)
			iconButton:FindChild("Sprite"):SetSprite(icon)
		end
		iconPicker:ArrangeChildrenTiles()

		for tracker, line in pairs(self.lineBinds.trackers) do
			local trackerLineSelect = self.trackerPanel:FindChild("Track" .. tracker):FindChild("LineSelectButton")
			trackerLineSelect:SetText(line)
			trackerLineSelect:FindChild("Sample"):SetSprite(self.lines[line].Sprite)
			trackerLineSelect:FindChild("Sample"):SetBGColor(self.lines[line].bgColor)
		end

		for hook, line in pairs(self.lineBinds.hooks) do
			local trackerLineSelect = self.trackerPanel:FindChild("Hook" .. hook):FindChild("LineSelectButton")
			trackerLineSelect:SetText(line)
			trackerLineSelect:FindChild("Sample"):SetSprite(self.lines[line].Sprite)
			trackerLineSelect:FindChild("Sample"):SetBGColor(self.lines[line].bgColor)
		end

		self:RepopulateLineList()
		
		self.xmlDoc = nil
		
		-- register our Addon so others can wait for it if they want
		g_AddonsLoaded["TrackMaster"] = true
		
		return Apollo.AddonLoadStatus.Loaded
	end
	return Apollo.AddonLoadStatus.Loading
end

function TrackMaster:RepopulateLineList()
	local lineList = self.wndMain:FindChild("LineList")
	local lineSelectList = self.trackerPanel:FindChild("LineSelectDropdown"):FindChild("LineSelectList")
	lineList:DestroyChildren()
	lineSelectList:DestroyChildren()
	for lineNo, line in pairs(self.lines) do
		local lineConfig = Apollo.LoadForm("TrackMaster.xml", "TrackMasterForm.LineList.LineConfig", lineList, self)
		lineConfig:SetData(line)
		lineConfig:FindChild("LineTitle"):SetText("Line " .. tostring(lineNo))
		lineConfig:FindChild("IconSelect"):FindChild("Sample"):SetSprite(line.Sprite)
		lineConfig:FindChild("ColorSelect"):FindChild("Sample"):SetBGColor(line.bgColor)
		lineConfig:FindChild("TrackTypeDropdown"):AddItem("Line", "", TrackLine.TrackMode.Line)
		lineConfig:FindChild("TrackTypeDropdown"):AddItem("Circle", "", TrackLine.TrackMode.Circle)
		lineConfig:FindChild("TrackTypeDropdown"):SelectItemByData(line.trackMode)
		lineConfig:FindChild("Distance"):SetText(line.distance)
		if line.trackMode == TrackLine.TrackMode.Circle then
			lineConfig:FindChild("Distance"):Show(true, true)
		else
			lineConfig:FindChild("Distance"):Show(false, true)
		end
		if lineNo == 1 then
			lineConfig:FindChild("DeleteButton"):Destroy()
		end

		local lineSelect = Apollo.LoadForm("TrackMaster.xml", "TrackerMicroPanel.LineSelectDropdown.LineSelectList.LineSelectButton", lineSelectList, self)
		lineSelect:SetText(tostring(lineNo))
		lineSelect:FindChild("Sample"):SetSprite(line.Sprite)
		lineSelect:FindChild("Sample"):SetBGColor(line.bgColor)
	end
	lineList:ArrangeChildrenVert()
	lineSelectList:ArrangeChildrenVert()
end

-----------------------------------------------------------------------------------------------
-- TrackMaster Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on timer
function TrackMaster:OnTimer()
	for _, line in pairs(self.lines) do
		line:Update()
	end
end

function TrackMaster:OnRotation()
	for _, line in pairs(self.lines) do
		line:UpdateRotation()
	end
end

function TrackMaster:OnMailbox()
	local distanceToPlayer = TrackLine.GetDistanceFunction()
	local closestMailbox = nil
	local closestMailboxDist = 0xffffff
	for _, mailbox in pairs(self.mailboxList) do
		local dist = distanceToPlayer(mailbox)
		if dist < closestMailboxDist then
			closestMailbox = mailbox
			closestMailboxDist = dist
		end
	end
	
	if closestMailbox ~= nil then
		self:SetTarget(closestMailbox, nil, self.lineBinds.trackers.Mailbox or 1)
	else
		Print("You're a long way from a mailbox...")
	end
end


function TrackMaster:OnTrackMasterOn()
	self.wndMain:Show(true)
end

function TrackMaster:OnUnitCreated(unit)
	if unit:GetType() == 'Mailbox' then
		self.mailboxList[unit:GetId()] = unit
	end
end

function TrackMaster:OnUnitDestroyed(unit)
	if unit:GetType() == 'Mailbox' then
		self.mailboxList[unit:GetId()] = nil
	end

	for lineNo, line in pairs(self.lines) do
		if unit == line.target then
			self:SetTarget(nil, lineNo)
		end
	end
end

function TrackMaster:UpdateHooks()
	if self.hooks["QuestHintArrow"] then
		self:AddHookQuestArrow()
	else
		self:RemoveHookQuestArrow()
	end
	
	if self.hooks["ZoneMap"] then
		self:AddHookZoneMap()
	else
		self:RemoveHookZoneMap()
	end	
	
	if self.hooks["GroupFrame"] then
		self:AddHookGroupFrame()
	else
		self:RemoveHookGroupFrame()
	end
	
	if self.hooks["GroupFrame"] then
		self:AddHookRaidFrame()
	else
		self:RemoveHookRaidFrame()
	end

	if self.hooks["Target"] then
		Print("RegisterEventHandler")
		Apollo.RegisterEventHandler("TargetUnitChanged", "OnTargetUnitChanged", self)
	else
		Apollo.RemoveEventHandler("TargetUnitChanged", self)
	end
end

function TrackMaster:UpdateTrackers()
	self:SetFocusTrackState(self.trackers.Focus)
end

function TrackMaster:AddHookQuestArrow()
	local questTracker = Apollo.GetAddon("QuestTracker")
	if questTracker ~= nil and self.hookedFunctions["QuestHintArrow"] == nil and self.hookedFunctions["QuestObjectiveHintArrow"] == nil then
		self.hookedFunctions["QuestHintArrow"] = questTracker.OnQuestHintArrow
		questTracker.OnQuestHintArrow = function(s, wndHandler, wndControl, eMouseButton)
			local quest = wndHandler:GetData():GetData()
			if quest ~= nil and Quest.is(quest) and # quest:GetMapRegions() > 0 then
				local pos = quest:GetMapRegions()[1].tIndicator
				self:SetTarget(Vector3.New(pos.x, pos.y, pos.z), nil, self.lineBinds.hooks["QuestArrow"] or 1)
			end
			self.hookedFunctions["QuestHintArrow"](s, wndHandler, wndControl, eMouseButton)
		end

		self.hookedFunctions["QuestObjectiveHintArrow"] = questTracker.OnQuestObjectiveHintArrow
		questTracker.OnQuestObjectiveHintArrow = function(s, wndHandler, wndControl, eMouseButton)
			local questHolder = wndHandler:GetData()
			
			if questHolder and questHolder.peoObjective then
				local quest = questHolder.peoObjective
				if quest ~= nil and Quest.is(quest) and # quest:GetMapRegions() > 0 then
					local pos = quest:GetMapRegions()[1].tIndicator
					self:SetTarget(Vector3.New(pos.x, pos.y, pos.z))
				end
			elseif questHolder and questHolder.queOwner then
				local quest = wndHandler:GetData().queOwner
				if quest ~= nil and Quest.is(quest) and # quest:GetMapRegions() > 0 then
					local pos = nil
					if wndHandler:GetData().nObjectiveIdx ~= nil then
						pos = quest:GetMapRegions()[math.min(#quest:GetMapRegions(), wndHandler:GetData().nObjectiveIdx + 1)].tIndicator
					else
						pos = quest:GetMapRegions()[1].tIndicator
					end
					self:SetTarget(Vector3.New(pos.x, pos.y, pos.z), nil, self.lineBinds.hooks["QuestArrow"] or 1)
				end
			end
			self.hookedFunctions["QuestObjectiveHintArrow"](s, wndHandler, wndControl, eMouseButton)
		end
	end
end

function TrackMaster:RemoveHookQuestArrow()
	if self.hookedFunctions["QuestHintArrow"] ~= nil then
		Apollo.GetAddon("QuestTracker").OnQuestHintArrow = self.hookedFunctions["QuestHintArrow"]
		self.hookedFunctions["QuestHintArrow"] = nil
	end
	if self.hookedFunctions["QuestObjectiveHintArrow"] ~= nil then
		Apollo.GetAddon("QuestTracker").OnQuestObjectiveHintArrow = self.hookedFunctions["QuestObjectiveHintArrow"]
		self.hookedFunctions["QuestObjectiveHintArrow"] = nil
	end
end

function TrackMaster:AddHookZoneMap()
	local zoneMap = Apollo.GetAddon("ZoneMap")
	if zoneMap ~= nil and self.hookedFunctions["ZoneMapClick"] == nil then
		self.hookedFunctions["ZoneMapClick"] = Apollo.GetAddon("ZoneMap").OnZoneMapButtonDown
		Apollo.GetAddon("ZoneMap").OnZoneMapButtonDown = function(s, wndHandler, wndControl, eButton, nX, nY, bDoubleClick)
			if eButton == GameLib.CodeEnumInputMouse.Right then
				local tPoint = zoneMap.wndZoneMap:WindowPointToClientPoint(nX, nY)
				local tWorldLoc = zoneMap.wndZoneMap:GetWorldLocAtPoint(tPoint.x, tPoint.y)
				local nLocX = math.floor(tWorldLoc.x + .5)
				local nLocZ = math.floor(tWorldLoc.z + .5)
				self:SetTarget(Vector3.New(nLocX, GameLib.GetPlayerUnit():GetPosition().y, nLocZ), nil, self.lineBinds.hooks["ZoneMap"] or 1)
			end			
			self.hookedFunctions["ZoneMapClick"](s, wndHandler, wndControl, eButton, nX, nY, bDoubleClick)
		end
	end
end

function TrackMaster:RemoveHookZoneMap()
	if self.hookedFunctions["ZoneMapClick"] ~= nil then
		Apollo.GetAddon("ZoneMap").OnZoneMapButtonDown = self.hookedFunctions["ZoneMapClick"]
		self.hookedFunctions["ZoneMapClick"] = nil
	end
end

function TrackMaster:AddHookGroupFrame()
	local groupFrame = Apollo.GetAddon("GroupFrame")
	if groupFrame ~= nil and self.hookedFunctions["GroupPortraitClick"] == nil then
		self.hookedFunctions["GroupPortraitClick"] = groupFrame.OnGroupPortraitClick
		groupFrame.OnGroupPortraitClick = function(s, wndHandler, wndControl, eMouseButton)
			local tInfo = wndHandler:GetData()
			local nMemberIdx = tInfo[1]
			local strName = tInfo[2]
			
			local unitMember = GroupLib.GetUnitForGroupMember(nMemberIdx)

			if nMemberIdx and unitMember then				
				self:SetTarget(unitMember, nil, self.lineBinds.hooks["GroupFrame"] or 1)
			end			
			self.hookedFunctions["GroupPortraitClick"](s, wndHandler, wndControl, eMouseButton)	
		end
	end
end

function TrackMaster:RemoveHookGroupFrame()
	if self.hookedFunctions["GroupPortraitClick"] ~= nil then
		Apollo.GetAddon("GroupFrame").OnGroupPortraitClick = self.hookedFunctions["GroupPortraitClick"]
		self.hookedFunctions["GroupPortraitClick"] = nil
	end
end

function TrackMaster:AddHookRaidFrame()
	local groupFrame = Apollo.GetAddon("RaidFrameBase")
	if groupFrame ~= nil and self.hookedFunctions["RaidMemberBtnClick"] == nil then
		self.hookedFunctions["RaidMemberBtnClick"] = groupFrame.OnRaidMemberBtnClick
		groupFrame.OnRaidMemberBtnClick = function(s, wndHandler, wndControl, eMouseButton)
			if wndHandler ~= wndControl or not wndHandler or not wndHandler:GetData() then
				return
			end

			local unit = GroupLib.GetUnitForGroupMember(wndHandler:GetData())
			if unit then
				self:SetTarget(unit, nil, self.lineBinds.hooks["GroupFrame"] or 1)
			end
			self.hookedFunctions["RaidMemberBtnClick"](s, wndHandler, wndControl, eMouseButton)	
		end
	end
end

function TrackMaster:RemoveHookRaidFrame()
	if self.hookedFunctions["RaidMemberBtnClick"] ~= nil then
		Apollo.GetAddon("RaidFrameBase").OnRaidMemberBtnClick = self.hookedFunctions["RaidMemberBtnClick"]
		self.hookedFunctions["RaidMemberBtnClick"] = nil
	end
end

-----------------------------------------------------------------------------------------------
-- TrackMasterForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function TrackMaster:OnOK()
	self.wndMain:Show(false) -- hide the window
end

-- when the Cancel button is clicked
function TrackMaster:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

function TrackMaster:OnAddLine( wndHandler, wndControl, eMouseButton )
	local newLine = TrackLine.new(self)
	table.insert(self.lines, newLine)
	self:RepopulateLineList()
end

function TrackMaster:OnIconSelect( wndHandler, wndControl, eMouseButton )
	local iconPicker = wndHandler:GetParent():GetParent()
	local lineConfig = iconPicker:GetData()
	lineConfig:GetData():SetSprite(wndHandler:FindChild("Sprite"):GetSprite())
	lineConfig:FindChild("IconSelect"):FindChild("Sample"):SetSprite(wndHandler:FindChild("Sprite"):GetSprite())
	iconPicker:Show(false, false)
end

function TrackMaster:OnIconPicker( wndHandler, wndControl, eMouseButton )
	local iconPicker = wndHandler:GetParent():GetParent():GetParent():FindChild("IconPicker")
	iconPicker:SetData(wndHandler:GetParent())
	iconPicker:Invoke()
end

function TrackMaster:OnOpenColorPicker( wndHandler, wndControl, eMouseButton )
	local line = wndHandler:GetParent():GetData()
	local color = line.bgColor
	self.colorPicker:OpenColorPicker(color, function()
		wndHandler:FindChild("Sample"):SetBGColor(color)
		line:SetBGColor(color)
	end)
end

function TrackMaster:OnDeleteLine( wndHandler, wndControl, eMouseButton )
	local lineItem = wndHandler:GetParent()
	local line = lineItem:GetData()

	for id, l in pairs(self.lines) do
		if l == line then
			table.remove(self.lines, id)

			local lineSelectList = self.trackerPanel:FindChild("LineSelectDropdown"):FindChild("LineSelectList")
			for _, lineSelect in pairs(lineSelectList:GetChildren()) do
				if tonumber(lineSelect:GetText()) == id then
					lineSelect:Destroy()
					break
				end
			end

			for hookId, hook in pairs(self.lineBinds.hooks) do
				if hook == tonumber(id) then
					self.lineBinds.hooks[hookId] = nil
				end
			end			

			for trackerId, tracker in pairs(self.lineBinds.trackers) do
				if tracker == tonumber(id) then
					self.lineBinds.trackers[trackerId] = nil
				end
			end
		end
	end
	lineItem:Destroy()
end

function TrackMaster:OnTrackTypeChanged(wndHandler, wndControl, id)
	local lineItem = wndHandler:GetParent():GetParent()
	local line = lineItem:GetData()

	if id == TrackLine.TrackMode.Circle then
		lineItem:FindChild("Distance"):Show(true, true)
	else
		lineItem:FindChild("Distance"):Show(false, true)
	end
	
	line:SetTrackMode(id)
end

function TrackMaster:OnDistanceChanged( wndHandler, wndControl, strText )
	local lineItem = wndHandler:GetParent()
	local line = lineItem:GetData()
	local distance = tonumber(wndHandler:GetText()) or 10
	
	line:SetDistance(distance)
end

---------------------------------------------------------------------------------------------------
-- TrackerMicroPanel Functions
---------------------------------------------------------------------------------------------------

function TrackMaster:OnClear( wndHandler, wndControl, eMouseButton )
	for lineNo, line in pairs(self.lines) do
		self:SetTarget(nil, nil, lineNo)
	end
end

function TrackMaster:OnToggleTrackList( wndHandler, wndControl, eMouseButton )
	self.trackerPanel:FindChild("HookList"):Show(false)
	local trackList = self.trackerPanel:FindChild("TrackList")
	trackList:Show(not trackList:IsShown())
end

function TrackMaster:OnToggleHookList( wndHandler, wndControl, eMouseButton )
	self.trackerPanel:FindChild("TrackList"):Show(false)
	local trackList = self.trackerPanel:FindChild("HookList")
	trackList:Show(not trackList:IsShown())
end

function TrackMaster:UpdateHookState( wndHandler, wndControl, eMouseButton )
	self.hooks[string.sub(wndHandler:GetName(), 5)] = wndHandler:IsChecked()
	self:UpdateHooks()
end

function TrackMaster:OnShow()
	self.trackerPanel:Show(true)
end

function TrackMaster:OnClose( wndHandler, wndControl, eMouseButton )
	self.trackerPanel:Show(false)
end

function TrackMaster:PinPanel( wndHandler, wndControl, eMouseButton )
	self.pinned = true
end

function TrackMaster:UnPinPanel( wndHandler, wndControl, eMouseButton )
	self.pinned = false
end

function TrackMaster:ShowOpacityWindow( wndHandler, wndControl, eMouseButton )
	self.trackerPanel:FindChild("Opacity"):Show(true)
end

function TrackMaster:OnOpacityChanged( wndHandler, wndControl, fNewValue, fOldValue )
	self:SetAlpha(fNewValue)
end

function TrackMaster:SetAlpha(value)
	self.alpha = value

	self.green.a = value
	self.yellow.a = value
	self.red.a = value
	
	self.trackerPanel:FindChild("Opacity"):SetText("Opacity: " .. string.format("%.2f", value))
	--self.wndMain:FindChild("Opacity"):SetText("Opacity: " .. string.format("%.2f", value))
end

function TrackMaster:UpdateTrackState( wndHandler, wndControl, eMouseButton )
	local trackName = wndHandler:GetParent():GetName():sub(6)
	if trackName == "Focus" then
		self:UpdateFocusTarget()
	end
end

function TrackMaster:LockTrackState( wndHandler, wndControl, eMouseButton )
	local trackName = wndHandler:GetName():sub(6)
	if trackName == "Focus" then	
		self:SetFocusTrackState(wndHandler:IsChecked())
	end
end

function TrackMaster:SetFocusTrackState(enabled)
	if enabled then
		self.trackers.Focus = true
		self:UpdateFocusTarget()
		Apollo.RegisterEventHandler("AlternateTargetUnitChanged", "UpdateFocusTarget", self)
	else
		Apollo.RemoveEventHandler("AlternateTargetUnitChanged", self)
	end
end

local function GetAlternateTarget()
	local playerUnit = GameLib.GetPlayerUnit()
	if playerUnit ~= nil then
		return playerUnit:GetAlternateTarget()
	end
	return nil
end

function TrackMaster:UpdateFocusTarget(newTarget)
	local focusTarget = newTarget or GetAlternateTarget()
	if focusTarget ~= nil then
		self:SetTarget(focusTarget, -1, self.lineBinds.trackers.Focus or 1)
	end
end

function TrackMaster:OnTargetUnitChanged(newTarget)
	local target = newTarget or GameLib.GetTargetUnit()
	self:SetTarget(target, -1, self.lineBinds.hooks.Target or 1)
end

function TrackMaster:OnLineSelect( wndHandler, wndControl, eMouseButton )
	self:OpenLineSelectDropdown(wndHandler, function(lineNo)
		local panelButton = wndHandler:GetParent()
		if panelButton:GetName():sub(1, 4) == "Hook" then
			if panelButton:GetName():sub(5) == "Target" then
				for lineId, line in pairs(self.lines) do
					line.trackTarget = lineId == lineNo
				end
			end
			self.lineBinds.hooks[panelButton:GetName():sub(5)] = lineNo
		else
			self.lineBinds.trackers[panelButton:GetName():sub(6)] = lineNo
		end
	end)
end

function TrackMaster:OpenLineSelectDropdown(button, callback)
	local lineSelectDropdown = self.trackerPanel:FindChild("LineSelectDropdown")
	lineSelectDropdown:Show(true, false)
	lineSelectDropdown:SetData({ btn = button, callback = callback })
end

function TrackMaster:OnLineSelected( wndHandler, wndControl, eMouseButton )
	local lineSelectButton = wndHandler:GetParent():GetParent():GetData().btn
	lineSelectButton:SetText(wndHandler:GetText())
	lineSelectButton:FindChild("Sample"):SetSprite(wndHandler:FindChild("Sample"):GetSprite())
	lineSelectButton:FindChild("Sample"):SetBGColor(wndHandler:FindChild("Sample"):GetBGColor())
	wndHandler:GetParent():GetParent():Show(false, false)
	wndHandler:GetParent():GetParent():GetData().callback(tonumber(wndHandler:GetText()))
end

-----------------------------------------------------------------------------------------------
-- TrackMaster Instance
-----------------------------------------------------------------------------------------------
local TrackMasterInst = TrackMaster:new()
TrackMasterInst:Init()

return TrackMaster
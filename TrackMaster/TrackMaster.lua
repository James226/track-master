-----------------------------------------------------------------------------------------------
-- Client Lua Script for TrackMaster
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- TrackMaster Module Definition
-----------------------------------------------------------------------------------------------
local TrackMaster = {} 

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
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
	self.clearDistance = 5
	
	self.hooks = {}
    return o
end

function TrackMaster:Init()
    Apollo.RegisterAddon(self)
end
 

-----------------------------------------------------------------------------------------------
-- TrackMaster OnLoad
-----------------------------------------------------------------------------------------------
function TrackMaster:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("TrackMaster.xml")
	self:OnMark()
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
	
	self.hooks["Target"] = tData["Hooks"]["Target"] == nil and true or tData["Hooks"]["Target"]
	self.hooks["QuestHintArrow"] = tData["Hooks"]["QuestHintArrow"] == nil and true or tData["Hooks"]["QuestHintArrow"]
	self.hooks["ZoneMap"] = tData["Hooks"]["ZoneMap"] == nil and true or tData["Hooks"]["ZoneMap"]
	self.hooks["GroupFrame"] = tData["Hooks"]["GroupFrame"] == nil and true or tData["Hooks"]["GroupFrame"]
	
	self.trackerPanel:FindChild("HookTarget"):SetCheck(self.hooks["Target"])
	self.trackerPanel:FindChild("HookQuestHintArrow"):SetCheck(self.hooks["QuestHintArrow"])
	self.trackerPanel:FindChild("HookZoneMap"):SetCheck(self.hooks["ZoneMap"])
	self.trackerPanel:FindChild("HookGroupFrame"):SetCheck(self.hooks["GroupFrame"])
	self:UpdateHooks()
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
		-- replace 'WhatToLookFor' with the name of the Addon you're waiting on
		-- and remove 'and false'
		return Apollo.AddonLoadStatus.Loading
	end

	if self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "TrackMasterForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return Apollo.AddonLoadStatus.LoadingError
		end	
		
		
	    self.wndMain:Show(false, true)	
		
		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil

		Apollo.RegisterSlashCommand("mailbox", "OnMailbox", self)
		
		Apollo.RegisterSlashCommand("trackmaster", "OnShow", self)
		
		Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
		Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)

		self.timer = ApolloTimer.Create(0.00001, true, "OnTimer", self)
			
		-- Do additional Addon initialization here
		
		-- register our Addon so others can wait for it if they want
		g_AddonsLoaded["TrackMaster"] = true
		
		return Apollo.AddonLoadStatus.Loaded
	end
	return Apollo.AddonLoadStatus.Loading
end

-----------------------------------------------------------------------------------------------
-- TrackMaster Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function TrackMaster:OnMark()
	self.marker = {}
	--local origPos = GameLib.GetPlayerUnit():GetPosition()
	--local pos = GameLib.GetPlayerUnit():GetPosition()
	for i = 0, 20 do
		self.marker[i] = Apollo.LoadForm("TrackMaster.xml", "Marker", "InWorldHudStratum", self)
		self.marker[i]:Show(true)
		
		--pos.x = origPos.x + 25 * math.cos(((2 * math.pi) / 20) * i)
		--pos.z = origPos.z + 25 * math.sin(((2 * math.pi) / 20) * i)
		--self.marker[i]:SetWorldLocation(pos)
	end
	
	--self.pos = GameLib.GetPlayerUnit():GetPosition()
end

-- on timer
function TrackMaster:OnTimer()
	local targetUnit = GameLib.GetTargetUnit()
	if GameLib.GetPlayerUnit() ~= nil and (self.target ~= nil or self.hooks["Target"] and targetUnit ~= nil) then
		local playerPos = GameLib.GetPlayerUnit():GetPosition()
		local targetPos = nil;
		if self.target ~= nil then
			if Vector3.Is(self.target) then
				targetPos = self.target
			elseif Unit.is(self.target) then
				targetPos = self.target:GetPosition()
			end
		end
		
		if targetPos == nil  then
			if targetUnit ~= nil then
				targetPos = targetUnit:GetPosition()
			else
				self:HideLine()
				return
			end
		end
		
		local distance = Vector3.New(0,0,0)
		distance.x = targetPos.x - playerPos.x
		distance.y = targetPos.y - playerPos.y
		distance.z = targetPos.z - playerPos.z
		local totalDistance = math.sqrt(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
		
		
		local color
		
		for i = 0, 20 do	
			local blobDistance = totalDistance * (1/20) * i	
			if blobDistance  <= 25 then
				color = self.green
			elseif blobDistance <= 35 then
				color = self.yellow
			else
				color = self.red
			end
			self.marker[i]:Show(true)	
			self.marker[i]:SetBGColor(color)
			self.marker[i]:SetWorldLocation(Vector3.InterpolateLinear(Vector3.New(playerPos.x, playerPos.y, playerPos.z), Vector3.New(targetPos.x, targetPos.y, targetPos.z), (1/20) * i))
		end
		
		if self.target ~= nil and self.clearDistance ~= -1 and totalDistance < self.clearDistance then
			self:SetTarget(nil)
		end
	else
		self:HideLine()
	end

end

function TrackMaster:HideLine()
	for i = 0, 20 do
		self.marker[i]:Show(false)
	end
end
function TrackMaster:OnMailbox()
	local playerPos = GameLib.GetPlayerUnit():GetPosition()
	local closestMailbox = nil
	local closestMailboxDist = 0xffffff
	for _, mailbox in pairs(self.mailboxList) do
		local pos = mailbox:GetPosition()
		local dist = self:CalculateDistance(Vector3.New(playerPos.x - pos.x, playerPos.y - pos.y, playerPos.z - pos.z))
		
		if dist < closestMailboxDist then
			closestMailbox = mailbox
			closestMailboxDist = dist
		end
	end
	
	if closestMailbox ~= nil then
		self:SetTarget(closestMailbox:GetPosition())
	else
		Print("You're a long way from a mailbox...")
	end
end


function TrackMaster:OnTrackMasterOn()
	self.wndMain:Show(true) -- show the window
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

	if unit == self.target then
		self:SetTarget(nil)
	end
end

function TrackMaster:CalculateDistance(vector)
	return math.sqrt(math.pow(vector.x, 2) + math.pow(vector.y, 2) + math.pow(vector.z, 2))
end

function TrackMaster:SetTarget(target, clearDistance)
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

	if clearDistance ~= nil then
		self.clearDistance = clearDistance
	else
		self.clearDistance = 5
	end

	self.target = target
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
end

function TrackMaster:AddHookQuestArrow()
	local questTracker = Apollo.GetAddon("QuestTracker")
	if questTracker ~= nil and self.hookedFunctions["QuestHintArrow"] == nil then
		self.hookedFunctions["QuestHintArrow"] = Apollo.GetAddon("QuestTracker").OnQuestHintArrow
		Apollo.GetAddon("QuestTracker").OnQuestHintArrow = function(s, wndHandler, wndControl, eMouseButton)
			local quest = wndHandler:GetData():GetData()
			if quest ~= nil and Quest.is(quest) and # quest:GetMapRegions() > 0 then
				local pos = quest:GetMapRegions()[1].tIndicator
				self:SetTarget(Vector3.New(pos.x, pos.y, pos.z))
			end
			self.hookedFunctions["QuestHintArrow"](s, wndHandler, wndControl, eMouseButton)
		end
	end
end

function TrackMaster:RemoveHookQuestArrow()
	if self.hookedFunctions["QuestHintArrow"] ~= nil then
		Apollo.GetAddon("QuestTracker").OnQuestHintArrow = self.hookedFunctions["QuestHintArrow"]
		self.hookedFunctions["QuestHintArrow"] = nil
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
				self:SetTarget(Vector3.New(nLocX, GameLib.GetPlayerUnit():GetPosition().y, nLocZ))
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
			local idx = wndHandler:GetData()
			if idx and GroupLib.GetGroupMember(idx) then	
				unitMember = GroupLib.GetUnitForGroupMember(idx)
				
				self:SetTarget(unitMember)
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
				self:SetTarget(unit)
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


---------------------------------------------------------------------------------------------------
-- TrackerMicroPanel Functions
---------------------------------------------------------------------------------------------------

function TrackMaster:OnClear( wndHandler, wndControl, eMouseButton )
	self:SetTarget(nil)
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
end

-----------------------------------------------------------------------------------------------
-- TrackMaster Instance
-----------------------------------------------------------------------------------------------
local TrackMasterInst = TrackMaster:new()
TrackMasterInst:Init()

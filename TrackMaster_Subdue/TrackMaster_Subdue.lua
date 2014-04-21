-----------------------------------------------------------------------------------------------
-- Client Lua Script for TrackMaster_Subdue
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- TrackMaster_Subdue Module Definition
-----------------------------------------------------------------------------------------------
local TrackMaster_Subdue = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function TrackMaster_Subdue:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.units = {}
	self.enabled = true

    return o
end

function TrackMaster_Subdue:Init()
    Apollo.RegisterAddon(self)
end
 

-----------------------------------------------------------------------------------------------
-- TrackMaster_Subdue OnLoad
-----------------------------------------------------------------------------------------------
function TrackMaster_Subdue:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("TrackMaster_Subdue.xml")
	
	self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)
	
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)	
end

function TrackMaster_Subdue:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
	local saveData = { }
	saveData["Enabled"] = self.enabled
	return saveData
end

function TrackMaster_Subdue:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	if tData["Enabled"] then
		self:Enable()
	else
		self:Disable()
	end
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Subdue GetAsyncLoadStatus
-----------------------------------------------------------------------------------------------
function TrackMaster_Subdue:GetAsyncLoadStatus()

	-- check for external dependencies here
	if g_AddonsLoaded == nil then
		g_AddonsLoaded = {}
	end
	if not g_AddonsLoaded["TrackMaster"] then
		return Apollo.AddonLoadStatus.Loading
	end

	if self.xmlDoc:IsLoaded() then
		local trackerPanel = Apollo.GetAddon("TrackMaster").trackerPanel
		
		self.trackerPanelWnd = Apollo.LoadForm(self.xmlDoc, "TrackMaster_Subdue", trackerPanel:FindChild("TrackList"), self)
		self.trackerPanelWnd:FindChild("SubdueEnabledButton"):SetCheck(self.enabled)
		trackerPanel:FindChild("TrackList"):ArrangeChildrenVert()
		self.xmlDoc = nil
		
		-- register our Addon so others can wait for it if they want
		g_AddonsLoaded["TrackMaster_Subdue"] = true
		
		return Apollo.AddonLoadStatus.Loaded
	end
	return Apollo.AddonLoadStatus.Loading 
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Subdue Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here


function TrackMaster_Subdue:CalculateDistance(vector)
	return math.sqrt(math.pow(vector.x, 2) + math.pow(vector.y, 2) + math.pow(vector.z, 2))
end

function TrackMaster_Subdue:OnUnitCreated(unit)
	if unit:GetType() == "Pickup" then
		local playerName = GameLib.GetPlayerUnit():GetName();
		if string.sub(unit:GetName(), 1, string.len(playerName)) == playerName then
			Apollo.GetAddon("TrackMaster"):SetTarget(unit, -1)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- TrackMaster_SubdueForm Functions
---------------------------------------------------------------------------------------------------

function TrackMaster_Subdue:Enable()
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
	Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
	self.enabled = true
end

function TrackMaster_Subdue:Disable()
	Apollo.RemoveEventHandler("UnitCreated", self)
	self.enabled = false
end

function TrackMaster_Subdue:OnEnableChecked( wndHandler, wndControl, eMouseButton )
	self:Enable()
end

function TrackMaster_Subdue:OnEnableUnChecked( wndHandler, wndControl, eMouseButton )
	self:Disable()
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Subdue Instance
-----------------------------------------------------------------------------------------------
local TrackMaster_SubdueInst = TrackMaster_Subdue:new()
TrackMaster_SubdueInst:Init()

-----------------------------------------------------------------------------------------------
-- Client Lua Script for TrackMaster_Farming
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming Module Definition
-----------------------------------------------------------------------------------------------
local TrackMaster_Farming = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function TrackMaster_Farming:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.units = {}
	self.enabled = true

    return o
end

function TrackMaster_Farming:Init()
    Apollo.RegisterAddon(self)
end
 

-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming OnLoad
-----------------------------------------------------------------------------------------------
function TrackMaster_Farming:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("TrackMaster_Farming.xml")
	
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
	Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)	
end

function TrackMaster_Farming:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
	local saveData = { }
	saveData["Enabled"] = self.enabled
	return saveData
end

function TrackMaster_Farming:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	if tData["Enabled"] then
		self:EnableFarming()
	else
		self:DisableFarming()
	end
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming GetAsyncLoadStatus
-----------------------------------------------------------------------------------------------
function TrackMaster_Farming:GetAsyncLoadStatus()

	-- check for external dependencies here
	if g_AddonsLoaded == nil then
		g_AddonsLoaded = {}
	end
	if not g_AddonsLoaded["TrackMaster"] then
		return Apollo.AddonLoadStatus.Loading
	end

	if self.xmlDoc:IsLoaded() then
		local trackerPanel = Apollo.GetAddon("TrackMaster").trackerPanel
		
		local numTrackers = # trackerPanel:FindChild("TrackList"):GetChildren()
		self.trackerPanelWnd = Apollo.LoadForm(self.xmlDoc, "TrackMaster_FarmingForm", trackerPanel:FindChild("TrackList"), self)
		self.trackerPanelWnd:FindChild("FarmingEnabledButton"):SetCheck(self.enabled)
		self.trackerPanelWnd:ArrangeChildrenVert()
		self.xmlDoc = nil
		
		self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)
		
		-- register our Addon so others can wait for it if they want
		g_AddonsLoaded["TrackMaster_Farming"] = true
		
		return Apollo.AddonLoadStatus.Loaded
	end
	return Apollo.AddonLoadStatus.Loading 
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on timer
function TrackMaster_Farming:OnTimer()
	if self.enabled and GameLib.GetPlayerUnit() then
		local playerPos = GameLib.GetPlayerUnit():GetPosition()
		local closestUnit = nil
		local closestUnitDist = 0xffffff
		for _, unit in pairs(self.units) do
			local pos = unit:GetPosition()
			local dist = self:CalculateDistance(Vector3.New(playerPos.x - pos.x, playerPos.y - pos.y, playerPos.z - pos.z))
	
			if dist < closestUnitDist then
				closestUnit = unit
				closestUnitDist = dist
			end
		end
		
		if closestUnit ~= nil then
			Apollo.GetAddon("TrackMaster"):SetTarget(closestUnit)
		end
	end
end

function TrackMaster_Farming:CalculateDistance(vector)
	return math.sqrt(math.pow(vector.x, 2) + math.pow(vector.y, 2) + math.pow(vector.z, 2))
end

function TrackMaster_Farming:OnUnitCreated(unit)
	if unit:GetType() == 'Harvest' and unit:CanBeHarvestedBy(GameLib.GetPlayerUnit()) then
		self.units[unit:GetId()] = unit
	end
end

function TrackMaster_Farming:OnUnitDestroyed(unit)
	if unit:GetType() == 'Harvest' and unit:CanBeHarvestedBy(GameLib.GetPlayerUnit()) then
		self.units[unit:GetId()] = nil
	end
end

---------------------------------------------------------------------------------------------------
-- TrackMaster_FarmingForm Functions
---------------------------------------------------------------------------------------------------

function TrackMaster_Farming:EnableFarming()
	if not self.enabled then
		self.enabled = true
		self.timer:Start()
	end
end

function TrackMaster_Farming:DisableFarming()
	if self.enabled then
		self.enabled = false
		self.timer:Stop()	
	end
end

function TrackMaster_Farming:OnEnableFarmingChecked( wndHandler, wndControl, eMouseButton )
	self:EnableFarming()
end

function TrackMaster_Farming:OnEnableFarmingUnChecked( wndHandler, wndControl, eMouseButton )
	self:DisableFarming()
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming Instance
-----------------------------------------------------------------------------------------------
local TrackMaster_FarmingInst = TrackMaster_Farming:new()
TrackMaster_FarmingInst:Init()

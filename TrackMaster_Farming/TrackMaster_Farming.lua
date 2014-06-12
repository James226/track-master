-----------------------------------------------------------------------------------------------
-- Client Lua Script for TrackMaster_Farming
-- Copyright (c) James Parker. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming Module Definition
-----------------------------------------------------------------------------------------------
local TrackMaster_Farming = {} 
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function TrackMaster_Farming:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    self.units = {}
	self.enabled = true
	self.selectedFilters = {}
	
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
	saveData.Enabled = self.enabled
	saveData.SelectedFilters = self.selectedFilters
	return saveData
end

function TrackMaster_Farming:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	if tData.Enabled then
		self:EnableFarming()
	else
		self:DisableFarming()
	end
	
	if tData.SelectedFilters then
		self.selectedFilters = tData.SelectedFilters
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
		trackerPanel:FindChild("TrackList"):ArrangeChildrenVert()
		self.xmlDoc = nil
		
		local professionIndex = {}	
		local professionDropdown = self.trackerPanelWnd:FindChild("MenuWindow"):FindChild("Professions"):FindChild("ProfessionsDropdown")
		professionDropdown:SetData(professionIndex)
		for _, profession in pairs(CraftingLib.GetKnownTradeskills()) do
			professionDropdown:AddItem(profession.strName, "", profession.eId)
			table.insert(professionIndex, profession)
		end
		
		local professionList = self.trackerPanelWnd:FindChild("MenuWindow"):FindChild("ProfessionsList")
		professionList:DestroyChildren()

		for _, profession in pairs(self.selectedFilters) do
			local filterOption = Apollo.LoadForm("TrackMaster_Farming.xml", "TrackMaster_FarmingForm.MenuWindow.ProfessionsList.ProfessionFilterOption", professionList, self)
			filterOption:SetData(profession)
			filterOption:SetText(profession.strName)
			self.selectedFilters[profession.strName] = profession
			professionList:ArrangeChildrenVert()
		end
		
		self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)
		
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
	
			if dist < closestUnitDist and self:IsInFilter(unit) then
				closestUnit = unit
				closestUnitDist = dist
			end
		end
		
		if closestUnit ~= nil then
			Apollo.GetAddon("TrackMaster"):SetTarget(closestUnit, 5, 2)
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

function TrackMaster_Farming:TableContainsElements(table)
	for _, _ in pairs(table) do
		return true
	end
	return false
end

function TrackMaster_Farming:IsInFilter(unit)
	return not self:TableContainsElements(self.selectedFilters) or self.selectedFilters[unit:GetHarvestRequiredTradeskillName()] ~= nil
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
		if self.timer ~= nil then
			self.timer:Stop()
		end
	end
end

function TrackMaster_Farming:OnEnableFarmingChecked( wndHandler, wndControl, eMouseButton )
	self:EnableFarming()
end

function TrackMaster_Farming:OnEnableFarmingUnChecked( wndHandler, wndControl, eMouseButton )
	self:DisableFarming()
end

function TrackMaster_Farming:OnOpenWindow( wndHandler, wndControl, x, y )
	self.trackerPanelWnd:FindChild("MenuWindow"):Show(true, false)
end

function TrackMaster_Farming:OnCloseMenu( wndHandler, wndControl, x, y )
	if not self.trackerPanelWnd:ContainsMouse() 
		and not self.trackerPanelWnd:FindChild("MenuWindow"):ContainsMouse()
		and not self.trackerPanelWnd:FindChild("MenuHook"):ContainsMouse() then
		self.trackerPanelWnd:FindChild("MenuWindow"):Show(false, false)
	end
end

function TrackMaster_Farming:OnAddTradeskillFilter( wndHandler, wndControl, selectedIndex)
	local professionIndex = wndHandler:GetData()
	if not self.selectedFilters[professionIndex[selectedIndex].strName] then
		local professionList = self.trackerPanelWnd:FindChild("MenuWindow"):FindChild("ProfessionsList")
		local filterOption = Apollo.LoadForm("TrackMaster_Farming.xml", "TrackMaster_FarmingForm.MenuWindow.ProfessionsList.ProfessionFilterOption", professionList, self)
		filterOption:SetData(professionIndex[selectedIndex])
		filterOption:SetText(professionIndex[selectedIndex].strName)
		wndControl:SetText("")
		self.selectedFilters[professionIndex[selectedIndex].strName] = professionIndex[selectedIndex]
		professionList:ArrangeChildrenVert()
	end
end

function TrackMaster_Farming:OnRemoveFilter( wndHandler, wndControl, eMouseButton )
	local professionList = self.trackerPanelWnd:FindChild("MenuWindow"):FindChild("ProfessionsList")
	for _, option in pairs(professionList:GetChildren()) do
		if option:IsChecked() then
			self.selectedFilters[option:GetData().strName] = nil
			option:Destroy()
		end
	end
	professionList:ArrangeChildrenVert()
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Farming Instance
-----------------------------------------------------------------------------------------------
local TrackMaster_FarmingInst = TrackMaster_Farming:new()
TrackMaster_FarmingInst:Init()

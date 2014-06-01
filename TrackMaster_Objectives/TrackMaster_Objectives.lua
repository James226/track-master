-----------------------------------------------------------------------------------------------
-- Client Lua Script for TrackMaster_Objectives
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- TrackMaster_Objectives Module Definition
-----------------------------------------------------------------------------------------------
local TrackMaster_Objectives = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function TrackMaster_Objectives:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	self.tUnits = {}
    -- initialize variables here

    return o
end

function TrackMaster_Objectives:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- TrackMaster_Objectives OnLoad
-----------------------------------------------------------------------------------------------
function TrackMaster_Objectives:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("TrackMaster_Objectives.xml")	
end

function TrackMaster_Objectives:GetAsyncLoadStatus()
	-- check for external dependencies here
	if g_AddonsLoaded == nil then
		g_AddonsLoaded = {}
	end
	if not g_AddonsLoaded["TrackMaster"] then
		return Apollo.AddonLoadStatus.Loading
	end

	if self.xmlDoc:IsLoaded() then
		self.wndMain = Apollo.LoadForm(self.xmlDoc,"Options",nil,self)
		local wndTrackerPanel = Apollo.GetAddon("TrackMaster").trackerPanel
		local trackMaster = Apollo.GetAddon("TrackMaster")
		self.pathConfig = trackMaster:AddToConfigMenu(trackMaster.Type.Track, "Path Mission", {
			CanFire = false,
			CanEnable = true,
			IsChecked = self.bTrackPathUnits,
			OnEnableChanged = function(isEnabled)
				self.bTrackPathUnits = isEnabled
			end
		})

		self.questConfig = trackMaster:AddToConfigMenu(trackMaster.Type.Track, "Quest", {
			CanFire = false,
			CanEnable = true,
			IsChecked = self.bTrackQuestUnits,
			OnEnableChanged = function(isEnabled)
				self.bTrackQuestUnits = isEnabled
			end
		})

		self.challengeConfig = trackMaster:AddToConfigMenu(trackMaster.Type.Track, "Challenge", {
			CanFire = false,
			CanEnable = true,
			IsChecked = self.bTrackChallengeUnits,
			OnEnableChanged = function(isEnabled)
				self.bTrackChallengeUnits = isEnabled
			end
		})

		Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
		Apollo.CreateTimer("TrackMaster_ObjectivesTimer",1,true)
		Apollo.RegisterTimerHandler("TrackMaster_ObjectivesTimer","OnTimer",self)
		Apollo.RegisterSlashCommand("TrackMaster_Objectives","OnSlash",self)
			-- register our Addon so others can wait for it if they want
		g_AddonsLoaded["TrackMaster_Objectives"] = true
		
		return Apollo.AddonLoadStatus.Loaded
	end
end

function TrackMaster_Objectives:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
	local saveData = {}
	saveData.bTrackQuestUnits = self.bTrackQuestUnits
	saveData.bTrackPathUnits = self.bTrackPathUnits
	saveData.bTrackChallengeUnits = self.bTrackChallengeUnits
	saveData.bIncludePrimes = self.bIncludePrimes
	return saveData
end

function TrackMaster_Objectives:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end
	
	self.bTrackQuestUnits = tData.bTrackQuestUnits
	self.bTrackPathUnits = tData.bTrackPathUnits
	self.bTrackChallengeUnits = tData.bTrackChallengeUnits
	self.bIncludePrimes = tData.bIncludePrimes
	self:SetButtonChecks()
end

-----------------------------------------------------------------------------------------------
-- TrackMaster_Objectives Functions
-----------------------------------------------------------------------------------------------
function TrackMaster_Objectives:OnUnitCreated(unit)
	if unit:IsValid() then
		self.tUnits[unit:GetId()] = unit
	end
end

function TrackMaster_Objectives:OnUnitDestroyed(unit)
	self.tUnits[unit:GetId()] = nil
end

function TrackMaster_Objectives:OnSlash()
	self.wndMain:Invoke()
end

function TrackMaster_Objectives:SetButtonChecks()
	if self.pathConfig then
		self.pathConfig:SetEnabled(self.bTrackPathUnits)
	end
	if self.questConfig then
		self.questConfig:SetEnabled(self.bTrackQuestUnits)
	end
	if self.challengeConfig then
		self.challengeConfig:SetEnabled(self.bTrackChallengeUnits)
	end
	if self.wndPathTrackerPanel then
		if self.wndPathTrackerPanel:FindChild("PathUnitButton") then
			self.wndPathTrackerPanel:FindChild("PathUnitButton"):SetCheck(self.bTrackPathUnits)
		end
	end
	if self.wndMain then
		if self.wndMain:FindChild("PrimeButton") then
			self.wndMain:FindChild("PrimeButton"):SetCheck(self.bIncludePrimes)
		end
	end
end

function TrackMaster_Objectives:GetUnitRewards(unitTarget)
	local tRewardInfo = unitTarget:GetRewardInfo()
	if tRewardInfo == nil then
		return
	end
	local nActiveRewardCount = 0
	local nRewardCount = (tRewardInfo ~= nil and #tRewardInfo or 0)
	if nRewardCount > 0 then
		for idx = 1, nRewardCount do
			local strType = tRewardInfo[idx].strType

			if strType == "Quest" and self.bTrackQuestUnits then
				return true
			elseif strType == "Challenge" and self.bTrackChallengeUnits then
				local bActiveChallenge = false
				local tAllChallenges = ChallengesLib.GetActiveChallengeList()
				for index, clgCurr in pairs(tAllChallenges) do
					if tRewardInfo[idx].idChallenge == clgCurr:GetId() and clgCurr:IsActivated() and not clgCurr:IsInCooldown() and not clgCurr:ShouldCollectReward() then
						bActiveChallenge = true
						break
					end
				end

				if bActiveChallenge then
					return true
				end
			elseif strType == "Soldier" or strType == "Settler" or strType == "Explorer" and self.bTrackPathUnits then
				return true
			elseif strType == "Scientist" and self.bTrackPathUnits then
				local pmMission = tRewardInfo[idx].pmMission
				local splSpell = tRewardInfo[idx].splReward

				if pmMission then
					local strMission = ""
					if pmMission:GetMissionState() >= PathMission.PathMissionState_Unlocked then
						if pmMission:GetType() == PathMission.PathMissionType_Scientist_FieldStudy then
							local tActions = pmMission:GetScientistFieldStudy()
							if tActions then
								for idx, tEntry in ipairs(tActions) do
									if not tEntry.bIsCompleted then
										return true
									end
								end
							end
						else
							return true
						end
					end
				end
			end	
		end
	end
	return
end

function TrackMaster_Objectives:OnTimer()
	if not (self.bTrackChallengeUnits or self.bTrackPathUnits or self.bTrackQuestUnits) then
		return
	end
	local unitPlayer = GameLib.GetPlayerUnit()
	local tPlayerPos
	local nShortestDist
	local unitClosest
	
	if unitPlayer then
		tPlayerPos = unitPlayer:GetPosition()
	else
		return
	end
	for nId,unit in pairs(self.tUnits) do
		if self:ValidateUnit(unit) then
			if self:GetUnitRewards(unit) then
				local nDist = self:GetDistance(unit:GetPosition(),tPlayerPos)
				if (not unitClosest) or (nDist < nShortestDist) then
					unitClosest = unit
					nShortestDist = nDist
				end
			end
		end
	end
	if unitClosest and unitClosest ~= self.unitLastSent then
		self:SendToTrackMaster(unitClosest)
		self.unitLastSent = unitClosest
		--Event_FireGenericEvent("SendVarToRover","Tracking",unitClosest:GetActivationState())
	end
end

function TrackMaster_Objectives:ValidateUnit(unit)
	if not unit:IsValid() then
		return
	end
	
	if unit:IsDead() then
		return
	end
	
	local tActivationState = unit:GetActivationState()

	if tActivationState and not (tActivationState.Interact or unit:ShouldShowNamePlate()) then
		return
	end

	if (not self.bIncludePrimes) and unit:GetRank() == Unit.CodeEnumRank.Elite then
		return
	end

	return true
end

function TrackMaster_Objectives:GetDistance(tPos1,tPos2)
	if not (tPos1 and tPos2) then
		return
	end
	local distance = Vector3.New(0,0,0)
	distance.x = tPos1.x - tPos2.x
	distance.y = tPos1.y - tPos2.y
	distance.z = tPos1.z - tPos2.z
	return math.sqrt(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
end

function TrackMaster_Objectives:OnLineSelect( wndHandler, wndControl, eMouseButton )
	Apollo.GetAddon("TrackMaster"):OnLineSelect(wndHandler, wndControl, eMouseButton)
end


function TrackMaster_Objectives:SendToTrackMaster(unit)
	Apollo.GetAddon("TrackMaster"):SetTarget(unit, -1)
end

---------------------------------------------------------------------------------------------------
-- Options Functions
---------------------------------------------------------------------------------------------------
function TrackMaster_Objectives:OnFormCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close()
end


function TrackMaster_Objectives:OnPrimeButtonCheck( wndHandler, wndControl, eMouseButton )
	self.bIncludePrimes = wndControl:IsChecked()
end

---------------------------------------------------------------------------
-- TrackMaster_Objectives Instance
-----------------------------------------------------------------------------------------------
local TrackMaster_ObjectivesInst = TrackMaster_Objectives:new()
TrackMaster_ObjectivesInst:Init()

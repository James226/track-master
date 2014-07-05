require "Window"

local Tracker  = {} 

function Tracker.new(trackMaster)
	local self = setmetatable({}, { __index = Tracker })

	self.targets = {}
	self.trackMaster = trackMaster
	if trackMaster ~= nil then
		self:SetLine(1)
	end

	return self
end

function Tracker:SetLine(lineNo)
	for lineNumber, line in pairs(self.trackMaster.lines) do
		if lineNo ~= lineNumber then
			line:RemoveTracker(self)
		end
	end
	self.trackMaster.lines[lineNo]:AddTracker(self)
end

local function indexOf(table, item)
	for key, value in pairs(table) do
		if (item == value) then
			return key
		end
	end
end

local function GetDistanceToTarget(playerVec, target)
	if Vector3.Is(target) then
		return (playerVec - target):Length()
	elseif Unit.is(target) then
		local targetPos = target:GetPosition()
		if targetPos == nil then
			return 0
		end
		local targetVec = Vector3.New(targetPos.x, targetPos.y, targetPos.z)
		return (playerVec - targetVec):Length()
	else
		local targetVec = Vector3.New(target.x, target.y, target.z)
		return (playerVec - targetVec):Length()
	end
end

function Tracker:AddTarget(target)
	if indexOf(self.targets, target) == nil then
		table.insert(self.targets, target)
	end
end

function Tracker:RemoveTarget(target)
	local index = indexOf(self.targets, target)
	if index ~= nil then
		table.remove(self.targets, index)
	end
end

function Tracker:ClearAllTargets()
	self.targets = {}
end

function Tracker:GetTarget()
	local closestTarget = nil
	local closestDistance = nil
	local playerUnit = GameLib.GetPlayerUnit()
	if playerUnit ~= nil then
		local playerPos = playerUnit:GetPosition()
		local playerVec = Vector3.New(playerPos.x, playerPos.y, playerPos.z)

		for _, target in pairs(self.targets) do
			local distance = GetDistanceToTarget(playerVec, target)
			if not closestTarget or distance < closestDistance then
				closestTarget = target
				closestDistance = distance
			end
		end
	end
	return closestTarget
end

if _G["TrackMasterLibs"] == nil then
	_G["TrackMasterLibs"] = {}
end
_G["TrackMasterLibs"].Tracker = Tracker
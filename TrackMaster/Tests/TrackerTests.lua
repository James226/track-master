describe("Tracker", function()
	local Tracker, tracker

	local function CreateUnit()
		local unit = {
			__position = {
				x = 0,
				y = 0,
				z = 0
			}
		}

		function unit:GetPosition()
			return unit.__position
		end

		return unit
	end

	setup(function()
		Tracker = _G['TrackMasterLibs']['Tracker']
	end)

	before_each(function()
		tracker = Tracker.new()
	end)

	describe("AddTarget", function()
		it("should add target to list", function()
			local target = CreateUnit()
			tracker:AddTarget(target)

			assert.are.same(1, #tracker.targets)
			assert.are.same(target, tracker.targets[1])
		end)

		it("should not add nil target to list", function()
			tracker:AddTarget(nil)
			assert.are.same(0, #tracker.targets)
		end)

		it("should not add same target to list multiple times", function()
			local target = CreateUnit()
			tracker:AddTarget(target)
			tracker:AddTarget(target)

			assert.are.same(1, #tracker.targets)
		end)
	end)

	describe("RemoveTarget", function()
		it("should not throw if target does not exist in list", function()
			local target = CreateUnit()
			assert.no_error(function() tracker:RemoveTarget(target) end)
		end)

		it("should remove target from list", function()
			local target = CreateUnit()
			tracker:AddTarget(target)
			tracker:RemoveTarget(target)

			assert.are.same(0, #tracker.targets)
		end)
	end)

	describe("GetTarget", function()
		local targetReceived = {}
		local callbackReceived = false
		local player

		before_each(function()
			player = CreateUnit()
			stub(GameLib, "GetPlayerUnit", function() return player end)
			stub(Unit, "is", function() return true end)
		end)

		after_each(function()
			GameLib.GetPlayerUnit:revert()
			Unit.is:revert()
		end)

		it("should return nil if no targets exist", function()
			assert.is_nil(tracker:GetTarget())
		end)

		it("should return target if only one exists", function()
			local target = CreateUnit()
			tracker:AddTarget(target)
			local trackerTarget = tracker:GetTarget()

			assert.is.not_nil(trackerTarget)
			assert.are.same(target, trackerTarget)
		end)

		it("should return closest target if multiple exist", function()
			local target1 = CreateUnit()
			target1.__position.x = 2
			tracker:AddTarget(target1)
			local target2 = CreateUnit()
			target2.__position.x = 1
			tracker:AddTarget(target2)

			assert.are.same(target2, tracker:GetTarget())
		end)
	end)

	describe("SetLine", function()
		local TrackMaster, trackMaster, TrackLine
		local loadedForms = {}

		setup(function()
			TrackMaster = Apollo.GetAddon("TrackMaster")

			Apollo.RegisterAddon = mock(Apollo.RegisterAddon, true, function (addon, bool, string, dependencies)
				addon:OnLoad()
			end)
		end)

		teardown(function()
			Apollo.RegisterAddon:revert()
		end)

		before_each(function()
			trackMaster = TrackMaster.new()
			TrackLine = mock(_G['TrackMasterLibs']['TrackLine'])
		end)

		after_each(function()
			unmock(TrackLine)
		end)

		it("should be assigned to line one by default", function()
			table.insert(trackMaster.lines, TrackLine.new())
			local tracker = Tracker.new(trackMaster)
			assert.spy(trackMaster.lines[1].AddTracker).was.called_with(trackMaster.lines[1], tracker)
		end)

		it("should be added to correct line", function()
			table.insert(trackMaster.lines, TrackLine.new())
			table.insert(trackMaster.lines, TrackLine.new())
			local tracker = Tracker.new(trackMaster)
			tracker:SetLine(2)

			assert.spy(trackMaster.lines[2].AddTracker).was.called_with(trackMaster.lines[2], tracker)
		end)

		it("should be removed from old line", function()
			table.insert(trackMaster.lines, TrackLine.new())
			table.insert(trackMaster.lines, TrackLine.new())
			local tracker = Tracker.new(trackMaster)
			tracker:SetLine(2)

			assert.spy(trackMaster.lines[1].RemoveTracker).was.called_with(trackMaster.lines[1], tracker)
		end)
	end)

	describe("Load", function()
		it("should not throw if nil is passed", function()
			local tracker = Tracker.new(trackMaster)
			assert.no_error(function() tracker:Load(nil) end)
		end)

		it("should set the line number from data", function()
			local tracker = Tracker.new(trackMaster)
			stub(tracker, "SetLine")

			tracker:Load({
				LineNo = 2
			})

			assert.stub(tracker.SetLine).was.called_with(tracker, 2)
		end)
	end)

	describe("Save", function()
		local TrackMaster, trackMaster
		setup(function()
			TrackMaster = Apollo.GetAddon("TrackMaster")

			Apollo.RegisterAddon = mock(Apollo.RegisterAddon, true, function (addon, bool, string, dependencies)
				addon:OnLoad()
			end)
		end)

		teardown(function()
			Apollo.RegisterAddon:revert()
		end)

		before_each(function()
			trackMaster = TrackMaster.new()
			TrackLine = mock(_G['TrackMasterLibs']['TrackLine'])
			table.insert(trackMaster.lines, TrackLine.new())
			table.insert(trackMaster.lines, TrackLine.new())
		end)

		after_each(function()
			unmock(TrackLine)
		end)

		it("should not return nil", function()
			local tracker = Tracker.new(trackMaster)
			assert.is.not_nil(tracker:Save())
		end)

		it("should set the current line number", function()
			local tracker = Tracker.new(trackMaster)
			tracker:SetLine(2)

			assert.is.same(2, tracker:Save().LineNo)
		end)
	end)
end)